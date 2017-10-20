<# 
.DESCRIPTION 
This script works two fold, it first deploys the edge than configures the LB

.NOTES
	File Name:NSXHorizonEdgeJumpstart.ps1
	
.OPTIONS
	None yet
	
.LINK
	Github https://github.com/Paikke/NSXHorizonJumpstart
	
.DEPENDENCIES
    VMware.PowerCLI
	PowerNSX
	PSYaml (included in the modules directory)

.INPUT
	Input file is taken from the settings for now. 
	Requires user interaction during script for NSX connection parameters

.OUTPUT
	Not yet
#>


# Deploy Edge as the first part

# Settings
$edgename = “name” #Name of the Edge
$edgedatastore = “datastore” # DS Location of the Edge
$cluster = "vdi-mgmt_cluster" # Cluster Resource
# Uplink is connected to the frontend network
$uplinkpg = "ManagementVDI" # Uplink is connected to Portgroup
$uplinkaddress = "10.1.1.1” #Uplink address
$secondaryaddress = "10.1.1.2” #Secondary address (VIP)
# Internal is used for HA that address will be added later
$internalpg = "VDIEDGEHA" # Internal is connected to Portgroup
$logon = "No" # No logging yet implemented
$enableHA = "1" # Enable HA on nic id
$syslogsvr = "vdisyslog.vTest.lab” # Syslog server to use for edge
$Password = ''

# Connection Stuff
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

### NSX Edge
# Build the uplink specifications
$uplink = New-NsxEdgeInterfaceSpec -Name UplinkVDI -Type Uplink -ConnectedTo (Get-vDPortgroup -Name $uplinkpg) -PrimaryAddress $uplinkaddress -SecondaryAddresses $secondaryaddress -SubnetPrefixLength 24 -Index 0

# Then Build the internal specifications
$internal1 = New-NsxEdgeInterfaceSpec -Name haint -Type Internal -ConnectedTo (Get-vDPortgroup -Name $internalpg) -Index 1

# New Large
New-NsxEdge -Name $edgename -Datastore (Get-Datastore -Name $edgedatastore) -cluster (Get-Cluster -Name $cluster) -Username admin -Password $Password -FormFactor Large -AutoGenerateRules -FwEnabled -FwDefaultPolicyAllow -EnableSyslog -SyslogServer $syslogsvr -SyslogProtocol tcp -Interface $uplink,$internal1 -EnableHA -HaVnic 1 -Connection $NSXConnection
