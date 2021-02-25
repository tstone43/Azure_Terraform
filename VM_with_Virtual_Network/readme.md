# Steps for Creating an Azure Windows VM that Leverages Key Vault
## Create a service principal for Terraform in Azure CLI:
1.  az login
2.  az account list
3.  az account set --subscription="SUBSCRIPTION_ID"
4.  az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
5.  Configure the following environment variables locally and use the values from previous command:
    export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
    export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
    export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
    export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
6.  
