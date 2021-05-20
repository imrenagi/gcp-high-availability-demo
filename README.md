# gcp-high-availability-demo

notes
== when cloud run is killed, traffic is not redirected to other cloud run instance. is it because of
health check done in neg?
>>> because it load balance based on capacity, not request. 
      setup load tester only in Indo. once it reaches max capacity then it load balance to singapore.
      >>> but this never found. probably because of the throtle in db
      ==> https://cloud.google.com/load-balancing/docs/negs/serverless-neg-concepts#limitations

An external HTTP(S) load balancer configured with a serverless NEG cannot detect if the underlying serverless resource (such as an App Engine, Cloud Functions, or Cloud Run (fully managed) service) is working as expected. This means that if your service in one region is returning errors but the overall Cloud Run (fully managed), Cloud Functions, or App Engine infrastructure in that region is operating normally, your external HTTP(S) load balancer will not automatically direct traffic away to other regions. Make sure you thoroughly test new versions of your services before routing user traffic to them.

== when instance group in us is scaled down to 0, we see the traffic from US get redirected to id
   >> traffic is slowly redirected, once no traffic served by server in US, it will get terminated.
   >> gcp drain the traffic to that instance group
>>> latency for us client is increased here

talking points:
* use case eatn
* single monolith located in Indonesia (user and payment)
* expand business to US
* each country has different regulation in terms of how to store data

                us                                indo
user data       anywhere is ok                    must be in indonesia
payment data    must be in us                     must be in indonesia

technical requirements:
* request to get user latency should be minimal in both US and Indo
* it is okay if us user get problem with write latency while saving their data
* latency for payment should be minimal in each country
* if there is zonal outage, the impact to the service might be minimal and should be ready in less than 5 mins
* database should be resilient againts zonal outage
* dont want to manage infra for payment. payment should be serverless and highly scalable.
* single multicast IP address
* breaking the monolith to small services.

* designing the endpoint.
  /users/api/v1/

  /payments/id/api/v1  ==> to ensure user in indonesia always store their data in indonesia
  /payments/us/api/v1

for demo:
testing high availability in stateful component
* do failover in database may be in user service.
  > check how long it recover both in id and us instance group.

testing high availability in stateless service
* scale down user service in us,
  > check whether the traffic from us is slowly get redirected to indonesia

* rollout new payment service in cloud run in singapore
  create new revision by setting env var FAIL=true
  > traffic should return 5xx because container is failing to serve the traffic (limitation)
  > explain about safe rollout with google cloud run.