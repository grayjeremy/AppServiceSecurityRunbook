# Azure App Service Security Runbook
The runbook will raise an error if a created or updated App Service is not running App Service Security. It uses the Microsoft Azure [Event Grid][4] to detect real-time changes to an app serivce that will activate this powershell runbook via a webhook. 
 

![alt text][AppServiceFunctions]
![alt text][AppServiceWebApp]

## Prerequisites: 
 * An [Azure Automation Account][1]
 * An "[AzureRunAsConnection][2]" asset the Automation Account

## Usage Instructions
Please refer to the [Integrate Azure Automation with Event Grid and Microsoft Teams][3], instead of finding a runbook in the gallery click "Add a runbook" and copy the text of "AppServiceSecurityRunbook" to the editor.  Instead of creating a VM to trigger the runbook, create a web app or function app. 

[1]: https://azure.microsoft.com/en-us/services/automation/
[2]: https://docs.microsoft.com/en-us/azure/automation/automation-connections
[3]: https://docs.microsoft.com/en-us/azure/event-grid/ensure-tags-exists-on-new-virtual-machines
[4]: https://azure.microsoft.com/en-us/services/event-grid/
[AppServiceFunctions]: images/function-authn-authz.png "Is App Service Authentication enabled for Functions"
[AppServiceWebApp]: images/webapp-authn-authz.png "Is App Service Authentication enabled for Web Apps"