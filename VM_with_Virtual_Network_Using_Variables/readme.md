# Improved Existing Configuration By Adding Variables
1.  Variables.tf file has now been created, which basically describes all the variables for the configuration and offers some reasonable defaults for the variables.
2.  Terraform.tfvars contains all the values that I wanted to pass for the variables that were setup
3.  In main.tf, existing Key Vault and existing Resource Group are no longer declared as resources.  I'm using "data" in Terraform now to access my existing Key Vault and retrieve the secrets.
