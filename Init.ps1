$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath

$utilitiesPath = Join-Path $scriptDirectory "Utilities.ps1"
Invoke-Expression ( ". {0}" -f $utilitiesPath )

if ( -not ( Test-Admin ) ) {
    Write-Host "Re-running this script as Admin"
    RunScriptAsAdmin $scriptPath
    return
}

Enable-PSRemoting -Force

if ( -not ( Test-Path C:\_cp ) ) {
    Write-Host "Creating directory C:\_cp"
    New-Item -Path C:\_cp -ItemType Directory | Out-Null
}

# Install Chocolately
if ( -not ( Test-Path Env:\ChocolateyInstall ) ) {
    Write-Host "Installing Chocolately"
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco install boxstarter -y

# Add the boxstarter modules to the current shell
$boxStarterShell = Join-Path $env:APPDATA "BoxStarter\BoxStarterShell.ps1"
Invoke-Expression ( "& '{0}'" -f $boxStarterShell )

# Take the box starter template script BoxStarter.Common and create a specific one with the package configs to run
$boxStarterCommon = Join-Path $scriptDirectory "Boxstarter.Common.ps1"
$boxStarterScript = Join-Path $scriptDirectory "Boxstarter.ps1"

if ( Test-Path $boxStarterScript ) {
    Remove-Item $boxStarterScript
}
Copy-Item $boxStarterCommon $boxStarterScript

$packagesCore = Join-Path $scriptDirectory "Packages.Core.config"
Add-Content -Path $boxStarterScript ( "`nchoco install '{0}' -y" -f $packagesCore )

# Run boxstarter
$Boxstarter.RebootOk = $true
Install-BoxstarterPackage $boxStarterScript
