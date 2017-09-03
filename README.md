# NSXHorizonJumpstart
Services file and script to jumpstart a NSX for Desktop Microsegmentation environment

This is based on the Horizon Service Installer VMware Fling https://labs.vmware.com/flings/horizon-service-installer-for-nsx#requirements

This project contains an editted services template file: Horizon7_service.yml where Horizon services and common infrastructures Firewall rules, service groups and security groups are defined and added. I am working on this file so it should be updated regarly.

This project will include a scripting mechanisme to implement these rules in NSX, with for example PowerNSX. Mainly to remove the requirement for Java with the current VMware Fling. 

For now the .yml file is maintained to be used by above VMware Fling.

I have created a PowerShell/PowerNSX script that starts the process of importing, but is not nearly ready. 
Currently only outside the master branch. To be released to master when appopriate.
Script currently does:
  - Check for yml file
  - read contents of yml file
  - Get input user for connecting to vCenter
  - Connect
  - Loop through Firewall services and checks if they exist
  - Log actions

Details will be posted on my blog https://pascalswereld.nl. 
Introduction blog post is released as https://pascalswereld.nl/2017/08/24/nsx-for-desktop-jumpstart-microsegmentation-with-horizon-service-installer-fling/.

For questions, suggestions and or remarks please do contact me.

Please use common sense and test before implementing in your environment. Don't go near production untested.
