# version 3
#This script install and configure Veeam backup agent for windows

# Store variables


$configfileuri = $args[0]
$licensefileuri = $args[1]
$installfileuri="https://veeaminstallmedia.blob.local.azurestack1.external/veeam2/VeeamAgentWindows_2.0.0.700.exe"

$folderName = “veeam”
$dest = “C:\WindowsAzure\$folderName”
$veeamagent = ‘Veeam_agent_install.exe’
$veeamlic = ‘Veeam_agent_windows_license’
$veeamconfig = ‘Veeam_config.xml’

Try{
mkdir $dest  -ea stop
}
Catch
{
    $dest_message=$_.Exception.Message
  
}
cd $dest


$logfile = "$dest\Veeambackup-agent-install-log_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

 

function log($string, $color)
{
   if ($Color -eq $null) {$color = "white"}
   write-host $string -foregroundcolor $color
   $string | out-file -Filepath $logfile -append
}
log "               Veeam Backup Agent installation          "
log "============================================================="
log $dest_message
log "Configuration file to use:$veeamconfig"
log "license file to use $veeamlic"
log "Downloading license and configuration files"

# Downloads Veeam agent and license file and Configuration file



Try {Invoke-WebRequest $installfileuri -OutFile $dest\$veeamagent}
Catch{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    log("the $configfileuri download failed,The error message was $ErrorMessage")
    Break
}
log("the $installfileuri downloaded successfully")

Try {Invoke-WebRequest $configfileuri -OutFile $dest\$veeamconfig}
Catch{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    log("the $configfileuri download failed,The error message was $ErrorMessage")
    Break
}
log("the $configfileuri downloaded successfully")



Try {Invoke-WebRequest $licensefileuri -OutFile $dest\$veeamlic}
Catch{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    log("the $licensefileuri download failed,The error message was $ErrorMessage")
    Break
}
log("the $licensefileuri downloaded successfully")



# Installs agent silent
#
$installation_code=(.\Veeam_agent_install.exe /silent /accepteula)
#.\Veeam_agent_install.exe /silent /accepteula

log ($installation_code)
Switch($installation_code)
{
"1000" {log " Veeam Agent for Microsoft Windows has been successfully installed."}
"1001" {log " prerequisite components required for Veeam Agent for Microsoft Windows have been installed on the machine. Veeam Agent for Microsoft Windows has not been installed. The machine needs to be rebooted."}
"1002" {log " Veeam Agent for Microsoft Windows installation has failed."}
"1101" {log "Veeam Agent for Microsoft Windows has been installed. The machine needs to be rebooted."}
"" {log "Please check if the veeam agent is already installed"}
}

# Add sleep before changing directory
#
Start-Sleep -Seconds 300
$path = ‘c:\Program Files\Veeam\Endpoint Backup’
cd $path

#
# Adds license and changes the Server edition
.\Veeam.Agent.Configurator.exe -license /f:$dest\$veeamlic /s
.\Veeam.Agent.Configurator.exe -import /f:$dest\$veeamconfig /s

<#
$error_code = (.\Veeam.Agent.Configurator.exe -license /f:$dest\$veeamlic /s)
if($error_code -eq 0)
{
log "license file applied successfully"
}
else{log "failed to apply given license "}


$error_code = (.\Veeam.Agent.Configurator.exe -import /f:$dest\$veeamconfig /s)
if($error_code -eq 0)
{
log "configurations applied successfully"
}
else{log "failed to apply given configuration file "}

 #>
