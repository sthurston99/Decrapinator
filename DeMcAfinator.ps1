$AdminPath = "C:\Admin\"
$TempPath = ($AdminPath + "temp\")
$MCPR = "https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe"
$mccArgs = "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE -v -s"

# Check for Admin Rights
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
If(-Not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Not running in elevated PowerShell"
    Write-Host -NoNewLine 'Press any key to exit...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    exit
}

# Test if Admin Path exists, create if nonexistant
If(!(Test-Path $AdminPath)) {
    New-Item $AdminPath -ItemType Directory
}

# Create temp path inside Admin Path
New-Item $TempPath -ItemType Directory

# Fetch MCPR
Invoke-WebRequest -Uri $MCPR -OutFile ($AdminPath + "MCPR.exe")

# Spawn MCPR
Start-Process ($AdminPath + "MCPR.exe") -Verb RunAs
Start-Sleep -Seconds 20

# Find extracted files in Temp
$mcprtmp = Get-ChildItem $Env:LocalAppData\Temp\*.tmp -Recurse -Directory |
    ForEach-Object {Get-ChildItem $_ -Recurse *mccleanup.exe} |
        Select-Object -First 1

# Copy extracted files to admin path for safety
Copy-Item -Path $mcprtmp.FullName.Replace("\mccleanup.exe","") -Destination $TempPath -Recurse

# Kill MCPR
Stop-Process -Name "McClnUi" -Force

# Run mccleanup
$p = Start-Process ($TempPath + "mccleanup.exe") -ArgumentList $mccArgs -PassThru -Wait -NoNewWindow

# Cleanup after running
Remove-Item -Path $TempPath -Recurse -Force