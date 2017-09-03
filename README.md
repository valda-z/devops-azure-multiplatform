# DEVOPS C# - Web App On and Azure SQL Database demo

This demo contains simple one page web app with REST API backend and Azure SQL Database for data persistence.

### Demonstrated DEVOPS scenario:
* automatically create infrastructure environment (Web App and Azure SQL Database).
* configure Web App with Azure SQL Database connection string and GitHub repository with application source codes for automated deployment.
* When developer changes application code and pushed changes to `cs` branch Web App collect changes from GitHub and deploy (and build) new version of application.

### Web App:
* exposes REST APIs for listing ToDoes, creating and editing ToDo records.


### Solution can be provisioned by this template, important attributes are:
* **sqlServerName** - The name of Azure SQL Server instance.
* **sqlAdministratorLogin** - SQLServer admin user name.
* **sqlAdministratorLoginPassword** - SQL Server admin password.
* **webAppName** - The name of Web App (used also for DNS name for web app *.azurewebsites.net).

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvalda-z%2Fdevops-azure-multiplatform%2Fcs%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

After successful deployment you can reach your application from web browser on URL: `https://[YOUR-WEBAPP-NAME].azurewebsites.net` 

### Note
After successful deployment you can change DevOps model from GitHub deployment to standard Continuos Delivery model:
* In Azure Portal select your Web App from resource group.
* Go to option "Continuous Delivery (Preview).
* Follow the wizard and create deployment via VTFS server.


