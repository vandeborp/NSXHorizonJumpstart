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
$logFile = "NSXHorizonJumpstart.log" # Log File location
# End of Settings

# Import Modules
Import-Module $PSScriptRoot\Modules\PSYaml
# Test not success Import-Module $PSScriptRoot\Modules\PSYaml\Private\ConvertFrom-YAMLDocument.ps1

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
Write-Log "Starting Log run $DateTime"

## Get yml file location and read the mumbling that is in there
# Check file location
if (!(Test-Path $ymlFile)) {
    # Exit script because required input file does not exist
	Write-Log "$ymlFile does not exist. Exiting script"
	throw "$ymlFile does not exist"
}else{
	Write-Log "$ymlFile found continuing import"
}
# End check file 

# Get that yml file
# Read Content of file
Write-Log "Read file contents"
$fileBody = Get-Content $PSScriptRoot\$ymlFile
ForEach ($line in $fileBody) {
	Write-Host $line
}

# Close Connections

Write-log "End script run"
# EOF




