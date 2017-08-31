<# 
.DESCRIPTION 
This script takes the yml configuration (setting) file as input
read and parses the values
connects to the vSphere/NSX environment
Checks the current environment for changes
Adds or overwrites changes
Set default to reject
Reports what has been set

Currently one script for functionality
depending on functions will add to different modules

.NOTES
	File Name:NSXHorizonJumpstart.ps1
	
.LINK
	Github https://github.com/Paikke/NSXHorizonJumpstart
	
.DEPENDENCIES
    VMware.PowerCLI
	PowerNSX

.INPUT
	Input file is taken from the settings. Requires user interaction during script

.OUTPUT
	Changed HTML report. Log file.
#>

# Settings
$ymlFile = "horizon7_Service.yml" # Input yml file
# End of Settings

## Get yml file location and read the mumbling that is in there
# Check file location
if (!(Test-Path $ymlFile)) {
    # Exit script because required input file does not exist
	throw "$ymlFile does not exist"
}
# End check file 




# EOF




