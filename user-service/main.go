package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"	
	"strings"
	"time"
	"io/ioutil"

	"github.com/bxcodec/faker/v3"
	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/plugin/dbresolver"

	"github.com/gorilla/mux"
	"github.com/rs/zerolog/log"
)

type resp struct {
	UUID string `json:"uuid"`
}

func GetMetadata(url string) (string, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}

	req.Header.Set("Metadata-Flavor", "Google")

	httpRes, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}

	bodyBytes, err := ioutil.ReadAll(httpRes.Body)
	if err != nil {		
		return "", err
	}

	return string(bodyBytes), nil
}


func main() {

	postgresHost, err := GetMetadata("http://metadata.google.internal/computeMetadata/v1/instance/attributes/postgres-host")
	if err != nil {
		log.Fatal().Err(err).Msg("unable to get postgres master host")
	}

	postgresReplicaHosts, err := GetMetadata("http://metadata.google.internal/computeMetadata/v1/instance/attributes/postgres-replica-hosts")
	if err != nil {
		log.Fatal().Err(err).Msg("unable to get postgres replica hosts")
	}

	db := "user-service"
	dbUser := "user-service"
	dbUserPassword := "password01"

	dsn := fmt.Sprintf("host=%s port=%s user=%s DB.name=%s password=%s sslmode=disable",
		postgresHost,
		"5432",
		dbUser,
		db,
		dbUserPassword)
	log.Debug().Msg(dsn)
	gormDB, err := gorm.Open(postgres.New(postgres.Config{DSN: dsn}), &gorm.Config{})
	if err != nil {
		log.Fatal().Err(err).Msg("unable to create db connection")
	}

	ips := strings.Split(postgresReplicaHosts, ",")
	fmt.Println(ips)
	fmt.Println(len(ips))

	err = gormDB.AutoMigrate(&User{})

	var dialectors []gorm.Dialector
	for _, ip := range ips {
		if ip == "" {
			continue
		}
		rdsn := fmt.Sprintf("host=%s port=%s user=%s DB.name=%s password=%s sslmode=disable", ip, "5432", dbUser, db, dbUserPassword)
		log.Debug().Msg(rdsn)
		config := postgres.Config{
			DSN: rdsn,
		}
		dialectors = append(dialectors, postgres.New(config))
	}

	if len(ips) > 0 {
		err := gormDB.Use(dbresolver.Register(dbresolver.Config{
			Replicas: dialectors,
			Policy:   dbresolver.RandomPolicy{},
		}),
		)
		if err != nil {
			log.Fatal().Err(err).Msg("unable to setup gorm plugin")
		}
		log.Debug().Msg("replicas are registered")
	}

	router := mux.NewRouter()
	srv := &Server{
		Router: router,
		db:     gormDB,
	}

	srv.routesV1()

	srv.Run(context.Background(), 80)
}

// Server ...
type Server struct {
	Router *mux.Router
	stopCh chan struct{}

	db *gorm.DB
}

// Run ...
func (g *Server) Run(ctx context.Context, port int) {

	httpS := http.Server{
		Addr:    fmt.Sprintf(":%d", port),
		Handler: g.Router,
	}

	// Start listener
	conn, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		log.Fatal().Err(err).Msgf("failed listen")
	}

	log.Info().Msgf("payment service serving on port %d ", port)

	go func() { g.checkServeErr("httpS", httpS.Serve(conn)) }()

	g.stopCh = make(chan struct{})
	<-g.stopCh
	if err := conn.Close(); err != nil {
		panic(err)
	}
}

// checkServeErr checks the error from a .Serve() call to decide if it was a graceful shutdown
func (g *Server) checkServeErr(name string, err error) {
	if err != nil {
		if g.stopCh == nil {
			// a nil stopCh indicates a graceful shutdown
			log.Info().Msgf("graceful shutdown %s: %v", name, err)
		} else {
			log.Fatal().Msgf("%s: %v", name, err)
		}
	} else {
		log.Info().Msgf("graceful shutdown %s", name)
	}
}

func (g *Server) routesV1() {

	g.Router.HandleFunc("/", hcHandler())

	// serve api
	api := g.Router.PathPrefix(fmt.Sprintf("/users/api/v1/")).Subrouter()
	api.HandleFunc("/", listUsers(g.db)).Methods("GET")
	api.HandleFunc("/", createUser(g.db)).Methods("POST")
}

func hcHandler() http.HandlerFunc {
	return func(rw http.ResponseWriter, r *http.Request) {
		rw.Write([]byte(`ok`))
	}
}

func listUsers(db *gorm.DB) http.HandlerFunc {
	return func(rw http.ResponseWriter, r *http.Request) {
		var users []User
		err := db.WithContext(r.Context()).Order("created_at desc").
			Limit(20).
			Find(&users).Error
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
			rw.Write([]byte(err.Error()))
			return
		}

		bytes, err := json.Marshal(users)
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
			rw.Write([]byte(err.Error()))
			return
		}

		rw.Header().Set("Content-Type", "application/json")
		rw.Write(bytes)
	}
}

type User struct {
	CreatedAt time.Time `json:"created_at" faker:"-"`
	UpdatedAt time.Time `json:"updated_at" faker:"-"`
	ID        uuid.UUID `gorm:"type:uuid;not null" json:"id" faker:"-"`
	Name      string    `gorm:"varchar(100);not null" json:"name" faker:"first_name"`
}

func (p *User) BeforeCreate(tx *gorm.DB) (err error) {
	uid, err := uuid.NewRandom()
	if err != nil {
		return err
	}
	p.ID = uid
	return nil
}

func createUser(db *gorm.DB) http.HandlerFunc {
	return func(rw http.ResponseWriter, r *http.Request) {

		user := &User{			
			ID: uuid.New(),
		}

		err := faker.FakeData(&user)
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
			rw.Write([]byte(err.Error()))
			return
		}

		err = db.WithContext(r.Context()).Save(user).Error
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
			rw.Write([]byte(err.Error()))
			return
		}

		bytes, err := json.Marshal(user)
		if err != nil {
			rw.WriteHeader(http.StatusInternalServerError)
			rw.Write([]byte(err.Error()))
			return
		}

		rw.Header().Set("Content-Type", "application/json")
		rw.Write(bytes)
	}
}
