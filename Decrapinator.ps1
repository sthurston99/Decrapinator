# Uninstall metro apps from predefined list.

$wares = curl https://raw.githubusercontent.com/sthurston99/Decrapinator/main/wares.txt
$registryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
IF(!(Test-Path $registryPath)){
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DisableWindowsConsumerFeatures" -PropertyType  "DWord" -Value 1 | Out-Null
} Else {
    New-ItemProperty -Path $registryPath -Name "DisableWindowsConsumerFeatures" -PropertyType  "DWord" -Value 1 | Out-Null
}

ForEach ($ware in $wares) {
    Get-AppXPackage -AllUsers $ware | Remove-AppxPackage
}

# Get uninstall strings for Office Click-To-Run versions
# Thanks, timurleng on r/sysadmin

$OfficeUninstallStrings = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where {$_.DisplayName -like "*Click-to-Run*"} | Select UninstallString).UninstallString

ForEach ($UninstallString in $OfficeUninstallStrings) {
    $UninstallEXE = ($UninstallString -split '"')[1]
    $UninstallArg = ($UninstallString -split '"')[2] + " DisplayLevel=False"
    Start-Process -FilePath $UninstallEXE -ArgumentList $UninstallArg -Wait
}
