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

Inorder to connect to the Cloud MySQL from SpringBoot application please follow the steps listed below and these 3 steps is mandatory whether you are running the conainers in cloud or local.

1) Clone the code from Google cloud github using the URL "git clone https://github.com/spring-cloud/spring-cloud-gcp"
2) After cloning the repository go to the directory "spring-cloud-gcp"
3) Run mvnw install (If the machine where you are running this command if it has a low memory it is advised to run it with skipTests & skipJavaDoc options). This command essentially installs the GCP libraries in local maven repository.

Make sure the build & install is successful 

For all dependencies please refer pom.xml under project root directory

4) MySQL username & password properties are added to the application properties file. <br/>
spring.datasource.username=root <br/>
spring.datasource.password=${CLOUD_SQL_DEV_DB_PASSWORD} # this is the environment variable

## Java programs that made up API

1) CustomerController
   - This is the implementation of API end point and implements the CRUD operations like createCustomer, getCustomer, updateCustomer & deleteCustomer. And this class in turn calls the CustomerDAO to get the data from MySQL database. CustomerDAO object is auto wired into this class using auto wire annotation.
2) CustomerDAO
   - This is the DAO implementation class that creates, updates & deletes the customer details. And this uses the spring JDBCTemplate out of box utitlity to interact with MySQL database.
   
## Containerizing the application and running on docker (Local machine or Google cloud shell)

To containerize the application please follow the steps. (Note: Please make sure the first 3 steps of section 'Connecting to Cloud MySQL from Spring Boot' are followed)

1) Clone this repository
2) A file with the name Dockerfile is created under project root directory
3) jib-maven-plugin is added to pom.xml (Please refer the file created under project root directory)
4) Run maven command "mvn compile jib:dockerBuild" to create the image 
5) Run the following command on the command/terminal. Please pay attention to the way we are passing environment variables(i.e., CLOUD_SQL_DEV_DB_PASSWORD, GOOGLE_APPLICATION_CREDENTIALS. Note: this is only needed when you are running the docker container for testing before deploying it to GKE) to the docker container. And the option SPRING_PROFILES_ACTIVE is used to tell the application what environment profile it needs to look for.
   - docker run -p 8080:8080 -e "SPRING_PROFILES_ACTIVE=dev" -e CLOUD_SQL_DEV_DB_PASSWORD='welcome1' 
   -v /Users/Raghu/gcp/:/var/gcp -e GOOGLE_APPLICATION_CREDENTIALS='/var/gcp/SpringMLProject-12a525884889.json' 
   -t springmlproject/customer:0.0.1-SNAPSHOT
6) Once the application runs successfully please access the URL http://localhost:8080/customer/all

## Deploying the application on Google Kubernetes Engine (GKE)

To deploy the application on GKE please follow the steps (Note: Please make sure the first 3 steps of section 'Connecting to Cloud MySQL from Spring Boot' are followed)

### Creating & Running docker image

1) Clone this repository in Google cloud shell
2) Run the maven command to push docker image to google container registry.
   - mvn compile jib:build
4) Run the docker container and see it is working
   - docker run -p 8080:8080 -e "SPRING_PROFILES_ACTIVE=dev" -e CLOUD_SQL_DEV_DB_PASSWORD='welcome1' -t gcr.io/springmlproject/customer:0.0.1-SNAPSHOT
5) open the localhost window in cloud shell and append the URL with /customer/all. This should display all the data exists in profile table.

### Deploying docker image on the GKE cluser

1) Run the deploy command
   - kubectl apply -f Deployment.yml
2) To view the deployment
   - kubectl get deployments
3) To see the application instances
   - kubectl get pods
4) To make the deployment visible to outside world
   - kubectl expose deployment dustomer --type=LoadBalancer
5) To get the public IP please run the command
   - kubectl get services
6) To access the application please use the url http://{public-ip}:8080/customer/all





