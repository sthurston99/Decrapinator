# Uninstall metro apps from predefined list.
$wares = (curl https://raw.githubusercontent.com/sthurston99/Decrapinator/main/wares.txt).content

# Prevent start-menu bloat and other crap
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryName = "DisableWindowsConsumerFeatures"

If(!(Test-Path $registryPath)){
	New-Item -Path $registryPath -Force | Out-Null
}
New-ItemProperty -Path $registryPath -Name $registryName -PropertyType "DWord" -Value 1 | Out-Null

# Run through uninstall process for Metro Apps
ForEach ($ware in $wares.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)) {
	# Uninstall on Current User
	If(Get-AppxPackage $ware) {
		Get-AppXPackage $ware | Remove-AppxPackage
	}
	# Uninstall on All Users
	If(Get-AppxPackage -AllUsers $ware) {
		Get-AppXPackage -AllUsers $ware | Remove-AppxPackage
	}
	# Prevent install for future users
	If(Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $ware}) {
		Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $ware} | Remove-AppxProvisionedPackage -Online | Out-Null
	}
}

# Get uninstall strings for Office Click-To-Run versions
# Thanks, timurleng on r/sysadmin

$OfficeUninstallStrings = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Click-to-Run*"} | Select-Object UninstallString).UninstallString

ForEach ($UninstallString in $OfficeUninstallStrings) {
	$UninstallEXE = ($UninstallString -split ' ')[0]
	$UninstallArg = ($UninstallString -split ' ')[1] + " DisplayLevel=False"
	Start-Process -FilePath $UninstallEXE -ArgumentList $UninstallArg -Wait
}
## Experimental: Remove McAfee Software
## Uncomment only if you are OK with testing this
# Invoke-WebRequest https://raw.githubusercontent.com/sthurston99/Decrapinator/main/DeMcAfinator.ps1 -OutFile "C:\Admin\DeMcAfinator.ps1"
# & ("C:\Admin\DeMcAfinator.ps1")