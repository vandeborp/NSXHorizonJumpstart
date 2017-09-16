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
	
.OPTIONS
	None yet
	
.LINK
	Github https://github.com/Paikke/NSXHorizonJumpstart
	
.DEPENDENCIES
    VMware.PowerCLI
	PowerNSX
	PSYaml (included in the modules directory)

.INPUT
	Input file is taken from the settings. 
	Requires user interaction during script for NSX connection parameters

.OUTPUT
	Changed HTML report. 
	Log file.
#>

# Settings
$ymlFile = "horizon7_Service.yml" # Input yml file
$logon = "Yes" # Do we want the script to log Yes or No
$logFile = "NSXHorizonJumpstart.log" # Log File location
$overwrite = "Yes" # Overwrite existing values, Yes or No
$defaultDeny = "Yes" # Set default Firewall Rule to Deny ## To be used later
$ReportOpt = "Yes" # Set the report option to Ye or No ## To be used later
$DFWLogon = "Yes" # Set the NSXFirewallRule to EnableLogging ## To be used later
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
If ($logon -eq "Yes") { Write-Log "Starting engines" }

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
	If ($logon -eq "Yes") { Write-Log "[ERROR] Horizon View Services section name not found but is required. Exit script" }
	throw "Horizon View Services section name not found but is required"
} # Can't propose user with default other than the default yml

If (!($fileBody.HorizonViewServices.protocol)){
	# Requires at least one HorizonViewServices.protocol to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Horizon View Services section protocol not found but is required. Exit script" }
	throw "Horizon View Services section protocol not found but is required"
} # Can't propose user with default other than the default yml

If (!($fileBody.HorizonViewServices.dest_ports)){
	# Requires at least one HorizonViewServices.dest_ports to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Horizon View Services section dest_ports not found but is required. Exit script" }
	throw "Horizon View Services section dest_ports not found but is required"
} # Can't propose user with default other than the default yml

If (!($fileBody.HorizonViewServices.source)){
	# Requires at least one HorizonViewServices.source to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Horizon View Services section source not found but is required. Exit script" }
	throw "Horizon View Services section source not found but is required"
} # Shall we propose user with Any? No we don't want that

If (!($fileBody.HorizonViewServices.description)){
	# Requires at least one HorizonViewServices.description to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Horizon View Services section description not found but is required. Exit script" }
	throw "Horizon View Services section description not found but is required"
} # Can't propose user with default other than the default yml

If ($logon -eq "Yes") { Write-Log "File yml contains at least one HorizonViewServices section. Continuing to process these." }

# Check next section
If (!($fileBody.DFWServiceGroups.name)){
	# Requires at least one DFWServiceGroups.name to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] DFWServiceGroups section name not found but is required. Exit script" }
	throw "DFWServiceGroups section name not found but is required"
} # Can't propose user with default other than the default yml

If ($logon -eq "Yes") { Write-Log "File yml contains at least one DFWServicesgroups section. Continuing to process these." }

# Next up Security Groups
# Check next section
If (!($fileBody.SecurityGroups)){
	# Requires at least the securityGroups section to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] SecurityGroups section name not found but is required. Exit script" }
	throw "SecurityGroups section not found but is required"
} # Can't propose user with default other than the default yml

If ($logon -eq "Yes") { Write-Log "File yml contains at least one Security Groups section. Continuing to process these." }

# Next up Firewall Rules And Section
# Check next section
If (!($fileBody.FirewallRules)){
	# Requires at least the FirewallRules section to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] FirewallRules section name not found but is required. Exit script" }
	throw "FirewallRules section not found but is required"
} # Can't propose user with default other than the default yml
If (!($fileBody.FirewallSections)){
	# Requires at least the FirewallSections section to be present
	# If we don't find exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] FirewallSections section name not found but is required. Exit script" }
	throw "FirewallSections section not found but is required"
} # Can't propose user with default other than the default yml


If ($logon -eq "Yes") { Write-Log "File yml contains at least Firewal section and rules. Continuing to process these." }

# We need further testing of other required components

# Parse the values

# Get input from user about
# NSX Manager
$nsxManager = Read-Host ("vCenter connected to NSX (FQDN/IP)")
If(!($nsxManager)){
	# no manager throw error and exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Asked user about vCenter/NSX manager. Got no usable response: $nsxManager" }
	throw "Asked user about vCenter/NSX manager. Got no usable response: $nsxManager"
}
If ($logon -eq "Yes") { Write-Log "Asked user about NSX manager. Got response: $nsxManager" }
# User
$nsxUser = Read-Host ("SSO NSX User to connect and with permissions to add")
If(!($nsxUser)){
	# no user throw error and exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Asked user about SSO NSX user. Got no usable response: $nsxUser" }
	throw "Asked user about SSO NSX User. Got no usable response: $nsxUser"
}
If ($logon -eq "Yes") { Write-Log "Asked user about SSO NSX User. Got response: $nsxUser" }
# Pass
# Will not log password
$nsxPass = Read-Host ("SSO user Password to connect")
If(!($nsxPass)){
	# no Pass throw error and exit
	If ($logon -eq "Yes") { Write-Log "[ERROR] Asked user about password. Got no usable response: <not logged>" }
	throw "Asked user about password. Got no usable response: $nsxPass"
}
If ($logon -eq "Yes") { Write-Log "Asked User about NSX Pass. Got response: <input not logged>" }
# Trust certificate?

# Open Connection
# Use as -connection $NSXConnection is the remainder of commands
If ($logon -eq "Yes") { Write-Log "Opening connection to NSX Manager" }
$NSXConnection = Connect-NsxServer -vCenterServer $nsxManager -username $nsxUser -Password $nsxPass #-DefaultConnection:$false

# Check input file with current NSX configuration
# Show changes
# Maybe a sure question if we find any with allow
# If user agrees change
# If user disagrees write to log and exit

# Horizon View Services Processing
$countSvc = 0
# Lets test if the service exists in NSX.
ForEach ($item in $fileBody.HorizonViewServices.name){
	 $itemfromNSX = Get-NsxService -name $item -connection $NSXConnection 
	 If (!$itemfromNSX) { 
		# Does not exist
		If ($logon -eq "Yes") { Write-Log "$item does not exist as service in NSX. Need to add" }
		# Get the other values that belong to service
		$itemProt = $fileBody.HorizonViewServices.protocol[$countSvc]
		$itemDest = $fileBody.HorizonViewServices.dest_ports[$countSvc]
		$itemSrc = $fileBody.HorizonViewServices.source[$countSvc]
		$itemDesc = $fileBody.HorizonViewServices.description[$countSvc]
		If ($logon -eq "Yes") { Write-Log "For $item there is $itemProt, DEST $itemDest, Src $itemSrc with description $itemDesc" }
		If(!($itemProt)){
			If ($logon -eq "Yes") { Write-Log "[ERROR] There is no protocol for $item" }
			throw " There is no protocol for $item"
		}
		If ($logon -eq "Yes") { Write-Log "$item Adding here" }
			New-NsxService -Name $item -Protocol $itemProt -port $itemDest -Description $itemDesc -connection $NSXConnection
	 }else{
		# Does exist check for overwrite
		# Later version will check on diffs in script
		If ($logon -eq "Yes") { Write-Log "$item does exist as service in NSX" }
		# Check for settings to overwrite
		If ($overwrite -eq "Yes") {
			# Will add overwrite in a later version
			# NeedsAdding
		}
	 }
	 $countSvc=$countSvc+1
}

# DFWServiceGroup processing
# Lets test if the service group exists in NSX.
ForEach ($itemSvcGr in $fileBody.DFWServiceGroups){
	 # Make $itemSvcGr.name human readable for logging
	 $itemSvcGrName = $itemSvcGr.name
	 $itemSvcGrfromNSX = Get-NsxServiceGroup -name $itemSvcGr.name -connection $NSXConnection 
	 If (!$itemSvcGrfromNSX) { 
		# Does not exist

		If ($logon -eq "Yes") { Write-Log "$itemSvcGrName does not exist as DFW Service Group in NSX. Need to add" }
		# Get the other values that belong to service
		$itemSvcGrChild = $itemSvcGr.children
		$itemSvcGrChildCnt = $itemSvcGr.children.Length
		# Posible run through
		# And check if services exist and no typos are here
		If(!($itemSvcGrChild)){
			If ($logon -eq "Yes") { Write-Log "[ERROR] There are no children for $itemSvcGr (=$itemSvcGrChild)" }
			throw " There is no children for $itemSvcGr (=$itemSvcGrChild)"
		}
		If ($logon -eq "Yes") { Write-Log "For $itemSvcGrName there are $itemSvcGrChildCnt children $itemSvcGrChild" }
		If ($logon -eq "Yes") { Write-Log "$itemSvcGrName Adding DFW Service Group here" }
			New-NsxServiceGroup -name $itemSvcGrName -connection $NSXConnection
		If ($logon -eq "Yes") { Write-Log "Adding children here" }
		# If children are gt 1 then loop else add 1
		If ($ItemSvcGrChildCnt -gt 1){
			# Loop
			ForEach ($SvcGrChild in $itemSvcGrChild) {
				If ($logon -eq "Yes") { Write-Log "$SvcGrChild added here" }
				# Get the service id
				$SvcGrChildId = Get-NsxService -name $SvcGrChild -connection $NSXConnection
				Get-NsxServiceGroup -name $itemSvcGrName -connection $NSXConnection | Add-NsxServiceGroupMember $SvcGrChildId -connection $NSXConnection
			}
		}else{
			#Just one
			$SvcGrChildId = Get-NsxService -name $SvcGrChild -connection $NSXConnection
			If ($logon -eq "Yes") { Write-Log "$itemSvcGrChild added here" }
			Get-NsxServiceGroup -name $itemSvcGrName -connection $NSXConnection | Add-NsxServiceGroupMember $SvcGrChildId -connection $NSXConnection
		}	
	 }else{
		# Does exist check for overwrite
		# Later version will check on diffs in script
		If ($logon -eq "Yes") { Write-Log "$itemSvcGrName does exist as DFW Service group in NSX" }
		# Check for settings to overwrite
		If ($overwrite -eq "Yes") {
			# Will add overwrite in a later version
			# NeedsAdding
		}
	 }
}

# DFW SecurityGroup processing
# Lets test if the security group exists in NSX.
# Nothing fancy yet, just the name and add empty one.
ForEach ($itemSecGr in $fileBody.SecurityGroups){
	 $itemSecGrfromNSX = Get-NsxSecurityGroup -name $itemSecGr -connection $NSXConnection 
	 If (!$itemSecGrfromNSX) { 
		# Does not exist
		If ($logon -eq "Yes") { Write-Log "$itemSecGr does not exist as DFW Security Group in NSX. Need to add" }
		# For now just adding the group
		New-NsxSecurityGroup -Name $itemSecGr -connection $NSXConnection
		# Something will be added 
	 }else{
		# Does exist check for overwrite
		# Later version will check on diffs in script
		If ($logon -eq "Yes") { Write-Log "$itemSecGr does exist as DFW Security group in NSX" }
		# Check for settings to overwrite
		If ($overwrite -eq "Yes") {
			# Will add overwrite in a later version
			# NeedsAdding
		}
	 }
}

# DFW Firewall Rules and Sections work together we need one for the other
# Add rules to sections
# Then add to NSX when not existing

# Sections and rules
ForEach ($itemFWSec in $fileBody.FirewallSections){
	 # Make human readable
	 $itemFWSecName = $itemFWSec.name
	 $itemFWSecfromNSX = Get-NSXFirewallSection -name $itemFWSec.name -connection $NSXConnection 
	 If (!$itemFWSecfromNSX) { 
		# Does not exist
		If ($logon -eq "Yes") { Write-Log "$itemFWSecName does not exist as DFW Firewall Section in NSX. Need to add" }
		# Get the other values for the section
		# Get the other values that belong to service
		$itemFWSecRules = $itemFWSec.firewallRules
		$itemFWSecRulesCnt = $itemFWSec.firewallRules.Length
		# And check if the rules exist and no typos are here
		If(!($itemFWSecRules)){
			If ($logon -eq "Yes") { Write-Log "[ERROR] There are no rules for $itemFWSec (=$itemFWSecRules)" }
			throw "There are no rules for $itemFWSec (=$itemFWSecRules)"
		}
		If ($logon -eq "Yes") { Write-Log "For $itemFWSecName there are $itemFWSecRulesCnt children $itemFWSecRules" }
		# First add the section
		New-NsxFirewallSection -name $itemFWSecName -connection $NSXConnection	
		# Something will be added in the firewallRules section
		# Check if Rules exist or need to be added 
		# Rules
		ForEach ($itemFWRule in $itemFWSecRules){
			# Make human readable
			$itemFWRuleName = $itemFWRule
			$itemFWRulefromNSX = Get-NSXFirewallRule -name $itemFWRuleName -connection $NSXConnection 
			If (!$itemFWRulefromNSX) { 
				# Does not exist
				If ($logon -eq "Yes") { Write-Log "$itemFWRuleName does not exist as DFW Firewall Section in NSX. Need to add" }
				# Get the other values for the rules from the file
				# Counter
				$countRules = 0 
				ForEach ($itemFWRuleFile in $fileBody.FirewallRules){
					# Make human readable
					$itemFWRuleFileName = $itemFWRuleFile.name
					If($itemFWRuleFileName -eq $itemFWRuleName){
						# This one we want
						$itemFWRuleSource = $itemFWRuleFile.source
						$itemFWRuleDest = $itemFWRuleFile.destination
						$itemFWRuleAction = $itemFWRuleFile.Action
						$itemFWRuleserviceGroup = $itemFWRuleFile.serviceGroup
						
						If(!($itemFWRuleSource)){
							If ($logon -eq "Yes") { Write-Log "[ERROR] There is no source for $itemFWRuleName (=$itemFWRuleSource)" }
							throw "There is no source for $itemFWRuleName (=$itemFWRuleSource)"
						}
						If ($logon -eq "Yes") { Write-Log "For $itemFWRuleName there is source: $itemFWRuleSource" }
						If(!($itemFWRuleDest)){
							If ($logon -eq "Yes") { Write-Log "[ERROR] There is no destination for $itemFWRuleName (=$itemFWRuleDest)" }
							throw "There is no destination for $itemFWRuleName (=$itemFWRuleDest)"
						}
						If ($logon -eq "Yes") { Write-Log "For $itemFWRuleName there is destination: $itemFWRuleDest" }		
						If(!($itemFWRuleAction)){
							If ($logon -eq "Yes") { Write-Log "[ERROR] There is no action for $itemFWRuleName (=$itemFWRuleAction)" }
							throw "There is no action for $itemFWRuleName (=$itemFWRuleAction)"
						}
						If ($logon -eq "Yes") { Write-Log "For $itemFWRuleName there is action: $itemFWRuleAction" }
						# Check Allow or Reject and warn if not Allow combined with zero trust Default Deny rule
						If($itemFWRuleAction -ne "Allow"){
							If ($logon -eq "Yes") { Write-Log "[WARN] There is a Reject or Block for $itemFWRuleName (=$itemFWRuleAction)" }
						}		

						# Get the SecurityGroup ID's for source and destination
			
						# Split om de id's op te halen
						$itemFWRuleSourceSplit = ($itemFWRuleSource -split ",")
						$RuleSplitCount = $itemFWRuleSourceSplit.count
						If ($logon -eq "Yes") { Write-Log "[DEBUG] Splitted sources in $RuleSplitCount times and items $itemFWRuleSourceSplit" }
						$itemFWRuleDestSplit = ($itemFWRuleDest -split ",")
						$DestSplitCount = $itemFWRuleDestSplit.count
						$itemFWRuleSrcID = @()
						For ($i = 0; $i -lt $RuleSplitCount; $i++){
							ForEach($itemRuleSourceSplit in $itemFWRuleSourceSplit){
								If ($logon -eq "Yes") { Write-Log "[DEBUG] Getting Source SecurityGroup ID for $itemRuleSourceSplit" }
								$SourceArgumentStr = $itemRuleSourceSplit
								$itemFWRuleSrcID += Get-NsxSecurityGroup -Name $SourceArgumentStr -connection $NSXConnection
							}
						}
						$itemFWRuleDestID = @()
						For ($z = 0; $z -lt $DestSplitCount; $z++){
						    ForEach($itemRuleDestSplit in $itemFWRuleDestSplit){
								If ($logon -eq "Yes") { Write-Log "[DEBUG] Getting Destination SecurityGroup ID for $itemRuleDestSplit" }
								$DestArgumentStr = $itemRuleDestSplit							
								$itemFWRuleDestID += Get-NsxSecurityGroup -Name $DestArgumentStr -connection $NSXConnection
							}
						}	
						$SrcArgument = $itemFWRuleSrcID
						$DestArgument = $itemFWRuleDestID
						If ($logon -eq "Yes") { Write-Log "[DEBUG] Sources Argument : $SrcArgument.name" }
						If ($logon -eq "Yes") { Write-Log "[DEBUG] Dest Argument : $DestArgument.name" }
						# Get Servicegroup ID's for service
						# PowerNSX checks on XML object if -service is a serviceGroup
						$SvcGrpArgument = Get-NsxServiceGroup -Name $itemFWRuleserviceGroup -connection $NSXConnection
						
						If ($logon -eq "Yes") { Write-Log "[DEBUG] ServiceGrp Argument : $SvcGrpArgument" }
						
						# Add new rule to Previously created section
						If ($logon -eq "Yes") { Write-Log "Adding new rule $itemFWRuleName to Section $itemFWSecName" }
						Get-NsxFirewallSection -name $itemFWSecName -connection $NSXConnection | New-NsxFirewallRule -name $itemFWRuleName -Source $SrcArgument -Destination $DestArgument -Action $itemFWRuleAction -Service $SvcGrpArgument -Connection $NSXConnection
					}
					$countRules=$countRules+1
				}
					
			}else{
				# Does exist check for overwrite
				# Later version will check on diffs in script
				# It is possible that rules exist in multiple sections but for now keep in one section to be clear.
				If ($logon -eq "Yes") { Write-Log "[WARN] $itemFWRuleName does exist as DFW Firewall Rule in NSX."}
				If ($logon -eq "Yes") { Write-Log "[WARN] $itemFWRuleName not advisable to add multiple same rules. Skipping"}
				# Check for settings to overwrite
				If ($overwrite -eq "Yes") {
					# Will add overwrite in a later version
					# NeedsAdding
				}
			}
		}		
	 }else{
		# Does exist check for overwrite
		# Later version will check on diffs in script
		If ($logon -eq "Yes") { Write-Log "$itemFWSecName does exist as DFW Firewall Section in NSX" }
		# Check for settings to overwrite
		If ($overwrite -eq "Yes") {
			# Will add overwrite in a later version
			# NeedsAdding
			# Is there a new rule to be added to an existing section?
			# Check for the rule and if not exist add to the section we are in
			
		}
		
	 }
}

# Close Connections

If ($logon -eq "Yes") { Write-log "End script run" }
# EOF




