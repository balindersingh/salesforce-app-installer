## Azure Devops custom task
*  an extension to install a managed package into an org by providing org *credential* and managed package's *namespace* and *package version* number

## Package the extension
* ```tfx extension create --manifest-globs vss-extension.json```
* for patch revision
* ```tfx extension create --manifest-globs vss-extension.json --rev-version```
* NOTE: we need to transpile *typescript* code first so to do that run ```tsc``` by going to buildAndReleaseTask folder. Also make sure you run ```npm install``` in that folder if you just download this solution first time.

## Commands for local testing
* To transpile typescript index file to javascript
* ```tsc```
* To run the actual code
* ```node index.js```
* Before executing the index.js file make sure you have setup environment variable for following which are basically parameters for task.
* ```export INPUT_SFSECURITYTOKEN="myusersecuritytoken"```
* ```export INPUT_SFUSERNAME="myscratchorguser@example.com"```
* ```export INPUT_SFPASSWORD="mysfpassword"```
* ```export INPUT_SFURL="https://test.salesforce.com"```
* ```export INPUT_APPVERSION="4.27"```
* ```export INPUT_APPNAMESPACE="SFPackageNamespace"```
* ```export INPUT_DEBUG="true"```

### Tips
* The agent doesn't automatically install the required modules because it's expecting your task folder to include the node modules. To mitigate this, copy the node_modules to buildAndReleaseTask. As your task gets bigger, it's easy to exceed the size limit (50MB) of a VSIX file. Before you copy the node folder, you may want to run ```npm install --production``` or ```npm prune --production```, or you can write a script to build and pack everything.

## Resources
* How-to's of Azure Devops custom task: https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops
* Salesforce package install: https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/packaging_api_introduction.htm