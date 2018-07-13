<#
.SYNOPSIS
    This runbook will check to see if an Azure App Service is running with App Service Security enabled.  It will write an error event if the setting is disabled.

.DESCRIPTION
    This runbook uses the "AzureRunAsConnection" connection from within an Automation Account https://azure.microsoft.com/en-us/services/automation/
    This runnbook can be installed in the same manner as described in the Micorosft documentation https://docs.microsoft.com/en-us/azure/event-grid/ensure-tags-exists-on-new-virtual-machines
    Please address all comments / issues / feature requests to the following GitHub repo https://github.com/grayjeremy/AppServiceSecurityRunbook

.PARAMETER WebhookData
    Optional. The information about the write event that is sent to this runbook from Azure Event grid.

.PARAMETER ChannelURL
    Optional. The Microsoft Teams Channel webhook URL where information should be sent.

.NOTES
    AUTHOR: Jeremy Gray https://github.com/grayjeremy/AppServiceSecurityRunbook
#>
Param(
    [parameter (Mandatory=$false)]
    [object] $WebhookData,

    [parameter (Mandatory=$false)]
    $ChannelURL
)

$RequestBody = $WebhookData.RequestBody | ConvertFrom-Json

$Data = $RequestBody.data

if(($Data.operationName -match "Microsoft.Web/sites/write" -or $Data.operationName -match "Microsoft.Web/sites/Config/write") -and $RequestBody.eventType -match "Microsoft.Resources.ResourceWriteSuccess")
{
    $ResourceId = $Data.resourceUri
    $ResourceId = $ResourceId -replace "/Config/authsettings", ""

    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Login-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    $resourceDetailsArray = $ResourceId.Split('/')
    Write-Output $("resourceDetailsArray: " + $resourceDetailsArray)

    $rgName = $resourceDetailsArray[4]
    $resourceType = "Microsoft.Web/sites/config"
    $resourceName = $resourceDetailsArray[8] + "/authsettings"

    $resource = Invoke-AzureRmResourceAction -ResourceGroupName $rgName -ResourceType $resourceType -ResourceName $resourcename -Action list -ApiVersion 2015-08-01 -Force

    if($null -eq $resource)
    {
         Write-Error $("Can't find object: " + $ResourceId)
         Write-Error $("Command Failed: 'Invoke-AzureRmResourceAction -ResourceGroupName " + $rgName + " -ResourceType " + $resourceType + " -ResourceName " + $resourcename + " -Action list -ApiVersion 2015-08-01 -Force'")
    }

    Write-Output $("resource: " + $resource)
    Write-Output $("resource.Properties: " + $resource.Properties)

    if(([System.Convert]::ToBoolean($resource.Properties.enabled)))
    {
        Write-Output $("Resource is using App Service Authentication: " + $ResourceId)
    }
    else
    {
            # call Teams webhook #need to add App Service Authentication to this or whatever makes sense with teams
            #Invoke-RestMethod -Method "Post" -Uri $ChannelURL -Body $RequestBody | Write-Verbose

            Write-Error $("Resource is NOT using App Service Authentication: " + $ResourceId)
    }
}
else
{
    Write-Output "Could not find App Service write event, this wasn't a 'Microsoft.Web/sites/write' or 'Microsoft.Web/sites/Config/write' event or the event type wasn't successful (Try filtering event grid to a single event type: 'Microsoft.Resources.ResourceWriteSuccess'"
}