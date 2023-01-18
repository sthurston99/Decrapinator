# Uninstall metro apps from predefined list.

$wares = curl https://raw.githubusercontent.com/sthurston99/Decrapinator/main/wares.txt

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType  "DWord" -Value 1

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
