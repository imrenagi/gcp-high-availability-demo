import time
from locust import HttpUser, task, between

class StartUser(HttpUser):
    wait_time = between(1, 2.5)

    @task
    def get_payment_id(self):
        self.client.get("/payments/id/api/v1/")

    @task
    def create_payment_id(self):
        self.client.post("/payments/id/api/v1/", json={})                

    @task
    def get_payment_us(self):
        self.client.get("/payments/us/api/v1/")

    @task
    def create_payment_us(self):
        self.client.post("/payments/us/api/v1/", json={})

    @task
    def get_users(self):
        self.client.get("/users/api/v1/")        

    @task
    def create_users(self):
        self.client.post("/users/api/v1/", json={})        