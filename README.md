# NSXHorizonJumpstart
Services file and script to jumpstart a NSX for Desktop Microsegmentation environment

This is based on the Horizon Service Installer VMware Fling https://labs.vmware.com/flings/horizon-service-installer-for-nsx#requirements

This project contains an editted services template file: Horizon7_service.yml where Horizon services and common infrastructures Firewall rules, service groups and security groups are defined and added. I am working on this file so it should be updated regarly.

This project will include a scripting mechanisme to implement these rules in NSX, with for example PowerNSX. Mainly to remove the requirement for Java with the current VMware Fling. 

For now the .yml file is maintained to be used by above VMware Fling.

I have created a PowerShell/PowerNSX script that starts the process of importing, but is quite nearly ready. 

Currently there is a test version in the master branch.
Script currently does:
  - Check for yml file
  - read contents of yml file
  - Get input user for connecting to vCenter
  - Connect
  - Loop through Firewall services and checks if they exist (Get-NsxService)
  - Log actions (can be turned of in settings part)
  - Add services to NSX if they do not exist (New-NsxService)
  - Loop through ServiceGroups and check if they exist (Get-NSxServiceGroup)
  - Add Servicesgroups in NSX when not existing (New-NsxServiceGroup)
  - within the servicegroups adds one or more children. (Get-NsxService for id and Get-NsxServiceGroup | Add-NsxServiceGroupMember)
  - Empty servicegroups with no children in the yml configuration will throw error
  - Loop through SecurityGroups and check if they exist (Get-NsxSecurityGroup)
  - Add SecurityGroup in NSX when not existing (New-NsxSecurityGroup)
  - Empty FirewallSection in the yml configuration will throw error
  - Loop through FirewallSections and check if they exist and have rules (Get-NsxFirewallSection)
  - Add FirewallSection in NSX when not existing (New-NsxFirewallSection)
  - Checks with that section for FireWall rules and adds these (Get-NsxFirewallSection | New-NsxFireWallRule)  
  
PowerNSX is essential, therefore please ensure you have the latest version of PowerNSX installed, which can be updated in an administrative PowerShell terminal with the following command (or use -User for installing in the user context):

Update-PowerNsx master (tested with master branch of 09/16/2017)  

Details will be posted on my blog https://pascalswereld.nl.  
Introduction blog post is released as https://pascalswereld.nl/2017/08/24/nsx-for-desktop-jumpstart-microsegmentation-with-horizon-service-installer-fling/.  
In between status and explaination of script when able to parse yml and add some services is release as  https://pascalswereld.nl/2017/09/04/powercli-collection-powernsx-desktop-jumpstart-and-process-yaml-yml-config-file/.  

For questions, suggestions and or remarks please do contact me.

Please use common sense and test before implementing in your environment. Don't go near production untested.
