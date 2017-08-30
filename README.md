# Function App and Azure Cosmos DB demo

This demo contains simple one page web app with REST API backend and Azure Cosmos DB for data persistence.

Function App:
* exposes REST APIs for listing ToDoes, creating and editing ToDo records.
* Function "StaticFileServer" together with proxy rules in Fuction App is able to serve static pages (located in folder www) - thanks Anthony Chu for great article about file serving from Function App: http://anthonychu.ca/post/azure-functions-static-file-server/ 


Solution can be provisioned by this template, important attributes are:
* App name - unique name for your Function App
* Repo URL - github url for your repository with application
* Branch - github branch which will be used
* Azure Cosmos Db name - unique name for your Cosmos DB
* Storage account type

After successful deployment you can reach your application from web browser on URL: `https://[YOUR-FUNCTIONAPP-NAME].azurewebsites.net` 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvalda-z%2Ffunctionapp-demo%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Notes:
If you want to change code or in another way to play with application use these steps:
* fork original repository (to be able to commit changes there) - original repo: https://github.com/valda-z/functionapp-demo
* when deploying application by template use your Repo URL in field "Repo URL"
* when you are done with changes you can git add; git commit; git push your changes to github, Function App will collect new version of files automatically in few seconds and you can see new version of your app deployed.