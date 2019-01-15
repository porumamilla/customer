# gke-springboot
This is a Spring Boot project. It is created to demonstrate how to create a sample API service in spring boot, 
how to containerize it as a docker container and how to deploy it on Google Kubernetes engine (GKE)

This is a sample API that uses Customer entity to describe CRUD operations like createCustomer, updateCustomer 
& deleteCustomer. Cloud SQL is used as a backend to store the Customer entity data. Spring boot & Docker container 
used as a micro service container. JDBC Template from Spring framework is used to persist the data.

## Sample Customer profile table created in Cloud MySQL 

MySQL [customer_master]> describe profile;<br/>

| Field        | Type         | Null | Key | Default           | Extra                       |
|--------------|--------------|------|-----|-------------------|-----------------------------|
| email        | varchar(255) | NO   | PRI | NULL              |                             |
| firstName    | varchar(255) | YES  |     | NULL              |                             |
| lastName     | varchar(255) | YES  |     | NULL              |                             |
| address      | varchar(500) | YES  |     | NULL              |                             |
| last_updated | timestamp    | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |


## Connecting to Cloud MySQL from Spring Boot

Inorder to connect to the Cloud MySQL from SpringBoot application please follow the steps listed below

1) Clone the code from Google cloud github using the URL "git clone https://github.com/spring-cloud/spring-cloud-gcp"
2) After cloning the repository go to the directory "spring-cloud-gcp"
3) Run mvnw install (If the machine where you are running this command if it has a low memory it is advised to run it with skipTests & skipJavaDoc options). This command essentially installs the GCP libraries in local maven repository.

Once the build & install is successful please add the following in pom.xml

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-gcp-starter-sql</artifactId>
    <version>1.0.0.BUILD-SNAPSHOT</version>
</dependency>
```
For all other dependencies please refer pom.xml under project root directory

4) Add the MySQL username & password to the application properties file <br/>
spring.datasource.username=root <br/>
spring.datasource.password=${CLOUD_SQL_DEV_DB_PASSWORD}

## Java programs that made up API
1) CustomerController
   - This is the implementation of API end point and implements the CRUD operations like createCustomer, getCustomer, updateCustomer & deleteCustomer. And this class in turn calls the CustomerDAO to get the data from MySQL database. CustomerDAO object is auto wired into this class using auto wire annotation.
2) CustomerDAO
   - This is the DAO implementation class that creates, updates & deletes the customer details. And this uses the spring JDBCTemplate out of box utitlity to interact with MySQL database.
   



