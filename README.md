# DEVOPS Node JS - Web App On Linux and Azure Cosmos DB (MongoDB) demo

This demo contains simple one page web app with REST API backend and MongoDB (Azure Cosmos DB) for data persistence.

### Demonstrated DEVOPS scenario:
* automatically create infrastructure environment (Web App and MongoDB).
* configure Web App with MongoDB credentials and GitHub repository with application source codes.
* When developer changes application code and pushed changes to `nodejs` branch Web App collect changes from GitHub and deploy new version of application.

### Web App:
* exposes REST APIs for listing ToDoes, creating and editing ToDo records.
* Azure Cosmos DB with MongoDB interface is used for data persistence 


### Solution can be provisioned by this template, important attributes are:
* **webAppName** - The name of Web App (used also for DNS name for web app *.azurewebsites.net).
* **mongoDbName** - The name of the MongoDB database (Azure Cosmos DB with MongoDB interface).

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvalda-z%2Fdevops-azure-multiplatform%2Fnodejs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

After successful deployment you can reach your application from web browser on URL: `https://[YOUR-WEBAPP-NAME].azurewebsites.net` 


