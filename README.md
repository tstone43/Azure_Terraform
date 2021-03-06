# Azure_Terraform
- Each folder in this repository represents different ways to deploy a Terraform VM and Virtual Network to Azure
- Note that the Network Security Group (NSG) in each example is configured to only allow your local IP for the Source Address 

## VM_with_Virtual_Network
- This shows how to create a service principal that can be used by Terraform to deploy your resources in Azure.
- This also shows how to assign a service principal to a Key Vault access policy, so that the service principal can retrieve secrets

## VM_with_Virtual_with_Virtual_Network_and_Backend
- A shell script is included that can be used in the Azure CLI to create a storage account to be used as the Terraform Backend, so that state files can be      maintained and also locked if in use.

## VM_with_Virtual_Network_Using_Variables
- This shows how to define input variables in the variables.tf file and then how to pass values for the input variables using terraform.tfvars file

## VM_with_Virtual_Network_Using_Modules
- This shows how to create the Windows server in a Terraform module

## VM_with_Virtual_Network_Using_CSE
- This shows how to create a Custom Script Extension (CSE) in the VM module
- This also shows to use a Dynamic block in the NSG resource to create multiple rules for the NSG 

