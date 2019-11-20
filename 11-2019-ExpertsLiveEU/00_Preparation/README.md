# Terraform - initial config

This project folder contains all code for your initial Terraform configuration.
The following configuration has been made and tested on macOS Mojave, Version 10.14.2 and macOS Catalina, Version 10.15.1.


## Content
This folder contains the following files:

| File | Description |
|------|-------------|
| README.md | this file |
| [00_createAzureADSP.sh](./00_createAzureADSP.sh) | Azure CLI script to create an Azure AD service principal |
| [01_createBackendStorageKeyVault.sh](./01_createBackendStorageKeyVault.sh) | Azure CLI script to create an Azure blob storage account as Terraform backend storage and an Azure KeyVault to store the storage account key |
| [02_environmentVariables.sh](./02_environmentVariables.sh) | Bash script to export environment variables |


## Install Terraform

You can install Terraform on macOS using brew:

```bash
brew update && brew install terraform
```


## Azure AD Preparation

For Terraform being able to authenticate against Azure AD you need an Azure AD service principal.

```bash
#!/bin/sh
SUBID=<your subscription id>
# Create Azure AD service principal in subscription $SUBID
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBID"
```


## Azure Infrastructure Preparation

We create an Azure Storage Account that is used as Terraform Remote Backend for storing the .tfstate file. The following Azure CLI script creates a new Azure Resource Group, Storage Account and Storage Container and stores the Storage Account key as a secret in a new Azure KeyVault.

```bash
#!/bin/bash

# Change these variables according to your needs
    RESOURCE_GROUP_NAME=ExpertsLiveEU
    STORAGE_ACCOUNT_NAME=eleu2019sa$RANDOM
    CONTAINER_NAME=tfstate
    VAULT_NAME=eleu2019kv$RANDOM
    SECRET_NAME=AccessKey-$STORAGE_ACCOUNT_NAME
    ARM_CLIENT_ID=yourServicePrincipalAppID

# Create Resource Group, Storage Account and Container for Terraform backend (securely storing Terraform plan)

# Create resource group
    az group create --name $RESOURCE_GROUP_NAME --location westeurope

# Create storage account
    az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
    ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

    echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
    echo "container_name: $CONTAINER_NAME"
    echo "access_key: $ACCOUNT_KEY"
    echo "Creating Key Vault: $VAULT_NAME"

# Create Azure Key Vault
    az keyvault create -g $RESOURCE_GROUP_NAME --name $VAULT_NAME 

# Set Azure Key Vault Access Policy
    az keyvault set-Policy --name $VAULT_NAME --secret-permissions get set --object-id $ARM_CLIENT_ID

# Set Azure Key Vault Secret value to storage account key
    az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value $ACCOUNT_KEY
```


## Export Environment Variables

You can add the following lines to your .bashrc or .bash_profile (depending on the operating system you use). The ARM_ACCESS_KEY variable is the storage account key you need to access the storage account you created before. The storage account key is exported into your bash environment everytime you start a shell session.

```bash
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
```