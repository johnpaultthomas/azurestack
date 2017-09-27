# version 3
#This script install and configure Veeam backup agent for windows

# Store variables


$configfileuri = $args[0]
$licensefileuri = $args[1]
$installfileuri= $args[2]

$folderName = “veeam”
$dest = “C:\WindowsAzure\$folderName”
$veeamagent = ‘Veeam_agent_install.exe’
$veeamlic = ‘Veeam_agent_windows_license’
$veeamconfig = ‘Veeam_config.xml’

mkdir $dest  -
$dest_message=$_.Exception.Message
cd $dest


$logfile = "$dest\Veeambackup-agent-install-log.txt"

function log($string, $color)
{
   if ($Color -eq $null) {$color = "white"}
   write-host $string -foregroundcolor $color
   $string | out-file -Filepath $logfile -append
}
log "Veeam Backup Agent installation $(get-date -format `"yyyyMMdd_hhmmsstt`")"
log $dest_message
log "Configuration file to use:$configfileuri"
log "License file to use $licensefileuri"
log "Install file to use $installfileuri"
log "Downloading files"

# Downloads Veeam agent and license file and Configuration file



Invoke-WebRequest $installfileuri -OutFile $dest\$veeamagent
log("the $installfileuri downloaded successfully")
Invoke-WebRequest $configfileuri -OutFile $dest\$veeamconfig
log("the $configfileuri downloaded successfully")
Invoke-WebRequest $licensefileuri -OutFile $dest\$veeamlic
log("the $licensefileuri downloaded successfully")



# Installs agent silent
log("Installing the Veeam Backp Agent")
.\Veeam_agent_install.exe /silent /accepteula
log("Sleeping for 90 seconds")
Start-Sleep -Seconds 90
$path = ‘c:\Program Files\Veeam\Endpoint Backup’
cd $path

#
# Adds license and configurations to the backup agent
log("Adds license and configurations to the backup agent")
.\Veeam.Agent.Configurator.exe -license /f:$dest\$veeamlic /s
.\Veeam.Agent.Configurator.exe -import /f:$dest\$veeamconfig /s

