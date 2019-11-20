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