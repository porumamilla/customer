# gke-springboot
This is a Spring Boot project. It is created to demonstrate how to create a sample API service in spring boot, 
how to containerize it as a docker container and how to deploy it on Google Kubernetes engine (GKE)

This is a sample API that uses Customer entity to describe CRUD operations like createCustomer, updateCustomer 
& deleteCustomer. Cloud SQL is used as a backend to store the Customer entity data. Spring boot & Docker container 
used as a micro service container. JDBC Template from Spring framework is used to persist the data.

MySQL [customer_master]> describe profile;<br/>

| Field        | Type         | Null | Key | Default           | Extra                       |
|--------------|--------------|------|-----|-------------------|-----------------------------|
| email        | varchar(255) | NO   | PRI | NULL              |                             |
| firstName    | varchar(255) | YES  |     | NULL              |                             |
| lastName     | varchar(255) | YES  |     | NULL              |                             |
| address      | varchar(500) | YES  |     | NULL              |                             |
| last_updated | timestamp    | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |
