1.  In the terraform-azure-server folder there is now a script called "postdeploy.ps1".  This script will install IIS on the VM and setup a funky web page.
2.  The terraform-server-module now makes use of a dynamic security rule where rules to allow HTTP and RDP can be easily set without making the NSG resource block in the main.tf too lengthy.
