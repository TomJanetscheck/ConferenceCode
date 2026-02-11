### basic configuration
$token = (Get-AzAccessToken -AsSecureString).token
$subscriptionId = read-host "Please enter your Azure subscription ID"
$resourceGroupName = read-host "Please enter your Azure resource group name"
$machineName = read-host "Please enter your Azure VM name"

### Read subscription-wide setting
$pricingUrlSubscription = "https://management.azure.com/subscriptions/" + $subscriptionId + "/providers/Microsoft.Security/pricings/virtualMachines?api-version=2024-01-01"
$result1 = Invoke-RestMethod -Method Get -Uri $pricingUrlSubscription -Token $token -Authentication Bearer
$result1.properties


### Read individual machine setting
$machineId = $subscriptionId + "/resourceGroups/" + $resourceGroupName + "/providers/Microsoft.Compute/virtualMachines/" + $machineName
$pricingUrlMachine = "https://management.azure.com/subscriptions/" + $machineId + "/providers/Microsoft.Security/pricings/virtualMachines?api-version=2024-01-01"
$result2 = Invoke-RestMethod -Method Get -Uri $pricingUrlMachine -Token $token -Authentication Bearer
$result2.properties


### Disable Defender for Servers on individual machine
$body = '{
    "properties": {
        "pricingTier": "Free"
    }
}'
$result3 = Invoke-RestMethod -Method Put -Uri $pricingUrlMachine -Body $body -ContentType 'application/json' -Token $token -Authentication Bearer
$result3.properties


### Enforce Defender for Servers Plan 1 on individual machine
$body = '{
    "properties": {
        "subPlan": "P1",
        "pricingTier": "Standard"
    }
}'
$result4 = Invoke-RestMethod -Method Put -Uri $pricingUrlMachine -Body $body -ContentType 'application/json' -Token $token -Authentication Bearer
$result4.properties

### Remove per-resource configuration on individual machine
Invoke-RestMethod -Method Delete -Uri $pricingUrlMachine -Token $token -Authentication Bearer
