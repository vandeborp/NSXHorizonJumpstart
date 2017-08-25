# NSXHorizonJumpstart
Services file and script to jumpstart a NSX for Desktop Microsegmentation environment

This is based on the Horizon Service Installer VMware Fling https://labs.vmware.com/flings/horizon-service-installer-for-nsx#requirements

This project contains an editted services template file: Horizon7_service.yml where Horizon services and common infrastructures Firewall rules, service groups and security groups are defined and added. I am working on this file so it should be updated regarly.

This project will include a scripting mechanisme to implement these rules in NSX, with for example PowerNSX or a web interface. Mainly to remove the requirement for Windows and Java with the current VMware Fling. 
For now the .yml file is maintained to be used by above VMware Fling.

Details will be posted on my blog https://pascalswereld.nl. Blog Post will be released shortly.

For questions, suggestions and or remarks please do contact me.

Please use common sense and test before implementing in your environment. Don't go near production untested.