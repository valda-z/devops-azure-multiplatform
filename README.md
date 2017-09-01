# DEVOPS JAVA - Web App on Linux, PostgreSQL, Jenkins, ACR

This demo contains simple one page web app with REST API backend (dockerized AJAVA Spring Boot application) and Azure PostgreSQL DB for data persistence.

### Demonstrated DEVOPS scenario:
* automatically create infrastructure environment WebApp, ACR, PostgreSQL, Jenkins).
* configure Jenkins with build job - Jenkins is able to build Maven project and push docker images to Azure Container Registry.
* PostgreSQL is configured with enabled firewall rules to all IP addresses.
* Web App for Linux is preconfigured to use ACR like private docker registry and jdbc connection to deployed PostgreSQL is injected to Web App configuration

### SpringBoot app:
* exposes REST APIs for listing ToDoes, creating and editing ToDo records.
* fronted is created in AngularJS 1.* and connected to backend REST APIs
* database table in PostgreSQL database is created automatically during application start 


### Solution can be provisioned by this template, important attributes are:
* **registryName** -The name of the container registry which will be deployed to Azure.
* **appImageName** - The name of application (used for docker image name).
* **webAppName** - The name of Web App (used also for DNS name for web app *.azurewebsites.net).
* **postgresName** - The name of Postgre SQL database.
* **postgresAdministratorLogin** - Administrator login for Postgre SQL database.
* **postgresAdministratorLoginPassword**" - Administrator login password for Postgre SQL database.
* **jenkinsName** - Name of Jenkins instance (also used like DNS prefix for Azure DNS name).
* **jenkinsAdminUsername** - Username for Jenkins operating system.
* **jenkinsSshPublicKey** - SSH public key for Jenkins operating system Username.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvalda-z%2Fdevops-azure-multiplatform%2Fjava%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


### After successful deployment:
* you can reach deployed Jenkins server (see DNS name on Overview pane of Jenkins Virtual Machine `http://[YUOR-JENKINS-DNS]:8080`
* You have to build docker image - from Jenkis management console `http://[YUOR-JENKINS-DNS]:8080` you can run build action on task `Basic Docker Build`
 * Login to Jenkis by username `admin`, password for admin user is stored in Jenkis VM  in file: `/var/lib/jenkins/secrets/initialAdminPassword`.
* you can reach your application from web browser on URL: `https://[YOUR-WEBAPP-NAME].azurewebsites.net` 

