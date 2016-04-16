#
# Used to bootstrap a new machine.  Example script to copy all files
# needed onto the new machine to initialise it.  This should be run
# from an admin powershell console
#

Set-ExecutionPolicy RemoteSigned -Force

if ( Test-Path C:\MachineConfig ) {
    Remove-Item C:\MachineConfig -Recurse -Force
}

$publicUser = Get-Credential -UserName STORAGE\Public -Message "Public user"
net use \\192.168.0.21\ipc$ /delete
net use \\192.168.0.21\ipc$ ( $publicUser.GetNetworkCredential().Password ) /user:Storage\Public

Copy-Item \\192.168.0.21\Public\MachineConfig c:\ -Recurse

c:\MachineConfig\Init.ps1