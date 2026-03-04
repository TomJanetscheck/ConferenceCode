Connect-AzAccount
$token = (Get-AzAccessToken -AsSecureString).token
$subscriptionId = read-host "Please enter your Azure subscription ID"
$MdeSettingsUrl = "https://management.azure.com/subscriptions/" + $subscriptionId + "/providers/Microsoft.Security/settings/wdatp?api-version=2022-05-01"

# Read MDE integration setting from subscription
$result1 = Invoke-RestMethod -Method Get -Uri $MdeSettingsUrl -Token $token -Authentication Bearer
$result1.properties