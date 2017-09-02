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
	PSYaml (included in the modules directory)

.INPUT
	Input file is taken from the settings. Requires user interaction during script

.OUTPUT
	Changed HTML report. Log file.
#>

# Settings
$ymlFile = "horizon7_Service.yml" # Input yml file
$logon = "Yes" # Do we want log Yes or No
$logFile = "NSXHorizonJumpstart.log" # Log File location
# End of Settings

# Import Modules
Import-Module $PSScriptRoot\Modules\PSYaml

# Function Declaration
function Write-Log 
{ 
    <# 
    .SYNOPSIS 
        This function creates or appends a line to a log file. 
 
    .PARAMETER  Message 
        The message parameter is the log message you'd like to record to the log file. 
 
    #> 
    [CmdletBinding()] 
    param ( 
        [Parameter(Mandatory)] 
        [string]$Message 
    ) 
     
    try 
    { 
        $DateTime = Get-Date -Format "dd-MM-yy HH:mm:ss"  
        Add-Content -Value "$DateTime - $Message" -Path "log\$logFile" 
    } 
    catch 
    { 
        Write-Error $_.Exception.Message 
    } 
}

# End Function Declaration

#########
# Run Baby Run
#########

## Init Log with current time
If ($logon -eq "Yes") { Write-Log "Starting Log run $DateTime" }

## Get yml file location and read the mumbling that is in there
# Check file location
if (!(Test-Path $ymlFile)) {
    # Exit script because required input file does not exist
	If ($logon -eq "Yes") { Write-Log "$ymlFile does not exist. Exiting script" }
	throw "$ymlFile does not exist"
}else{
	If ($logon -eq "Yes") { Write-Log "$ymlFile found continuing import" }
}
# End check file 

# Get that yml file
# Read Content of file
If ($logon -eq "Yes") { Write-Log "Reading file contents" }

# Get content and Convert from yaml to variabel
# To be called Section And context
# 
# $fileBody = Get-Content $PSScriptRoot\$ymlFile -Raw -ErrorAction:SilentlyContinue | ConvertFrom-YAMLDocument -ErrorAction:SilentlyContinue
$fileBody = Get-Content $PSScriptRoot\$ymlFile -Raw -ErrorAction:SilentlyContinue | ConvertFrom-Yaml -ErrorAction:SilentlyContinue

# Do smth with content
# First test if input we expect is present
If (!($fileBody.HorizonViewServices.name)){
	# Requires at least one HorizonViewServices.name to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "Horizon View Services section name not found but is required. Exit script" }
	throw "Horizon View Services section name not found but is required"
} # Can't propose user with default other than the default yml

If (!($fileBody.HorizonViewServices.protocol)){
	# Requires at least one HorizonViewServices.protocol to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "Horizon View Services section protocol not found but is required. Exit script" }
	throw "Horizon View Services section protocol not found but is required"
} # Can't propose user with default other than the default yml

If (!($fileBody.HorizonViewServices.dest_ports)){
	# Requires at least one HorizonViewServices.dest_ports to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "Horizon View Services section dest_ports not found but is required. Exit script" }
	throw "Horizon View Services section dest_ports not found but is required"
} # Can't propose user with default other than the default yml

If (!($fileBody.HorizonViewServices.source)){
	# Requires at least one HorizonViewServices.source to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "Horizon View Services section source not found but is required. Exit script" }
	throw "Horizon View Services section source not found but is required"
} # Shall we propose user with Any? No we don't want that

If (!($fileBody.HorizonViewServices.description)){
	# Requires at least one HorizonViewServices.description to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "Horizon View Services section description not found but is required. Exit script" }
	throw "Horizon View Services section description not found but is required"
} # Can't propose user with default other than the default yml

If ($logon -eq "Yes") { Write-Log "File yml contains at least one HorizonViewServices section. Continuing." }




# For writers debugging
Write-Host $fileBody.HorizonViewServices.name
Write-Host $fileBody.HorizonViewServices.protocol
Write-Host $fileBody.HorizonViewServices.dest_ports
Write-Host $fileBody.HorizonViewServices.source
Write-Host $fileBody.HorizonViewServices.description


# Get input from user about
# NSX Manager
# User
# Pass
# Trust certificate

# Open Connection

# Check input file with current NSX configuration
# Show changes
# Get agreement of user of changes/adding
# Maybe a sure question if we find any with allow
# If user agrees change
# If user disagrees write to log and exit

# Close Connections

If ($logon -eq "Yes") { Write-log "End script run" }
# EOF




