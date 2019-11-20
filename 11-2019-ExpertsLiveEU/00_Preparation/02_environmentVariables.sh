#!/bin/bash
echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID=yourSubscriptionID
export ARM_CLIENT_ID=yourServicePrincipalAppID
export ARM_CLIENT_SECRET=yourServicePrincipalPassword
export ARM_TENANT_ID=yourAzureADTenantID
# Login to Azure AD with the service principal
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
export ARM_ACCESS_KEY=$(az keyvault secret show --name yourKeyVaultSecretName --vault-name yourKeyVaultName --query value -o tsv)
# Not needed for public, required for usgovernment, german, china
export ARM_ENVIRONMENT=public