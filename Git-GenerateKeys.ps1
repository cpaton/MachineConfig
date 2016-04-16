function GenerateSshKey() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 1, Mandatory = $true)]
        [string] $SshKeyName,
        [Parameter(Position = 2, Mandatory = $true)]
        [string] $Comment
    )

    $sshKeyPath = Join-Path $env:USERPROFILE ( ".ssh\{0}" -f $SshKeyName )

    if ( Test-Path $sshKeyPath ) {
        Remove-Item $sshKeyPath -Force
    }

    $sshKeys = @{
        Private = ( "~/.ssh/{0}" -f $SshKeyName )        
    }
    $sshKeys["Public"] = $sshKeys["Private"] + ".pub"
    
    $generateCommand = '& ''C:\Program Files\Git\bin\sh.exe'' --login -i -c ''ssh-keygen -t rsa -b 4096 -C ""{0}"" -f {1} -N """"''' -f $Comment, $sshKeys["Private"]
    Write-Verbose $generateCommand
    Invoke-Expression $generateCommand

    New-Object -TypeName PsObject -Property $sshKeys
}

function Get-SshConfig() {
    [CmdletBinding()]
    param()

    $sshConfigFilePath = Join-Path $env:USERPROFILE ".ssh\config"

    if ( -not ( Test-Path $sshConfigFilePath ) ) {
        return @{}
    }

    $configContent = Get-Content -Path $sshConfigFilePath
    $sshConfig = @{}
    $currentHostName = $null
    $currentHostSettings = $null

    foreach ( $line in $configContent ) {
        if ( $line -match '^\s*Host\s+(?<name>.+)$' ) {
            if ( $currentHostName -ne $null ) {
                $sshConfig[$currentHostName] = $currentHostSettings
            }

            $currentHostName = $Matches["name"].Trim()
            $currentHostSettings = @{}
        }
        elseif ( $line -match '^\s*(?<setting>.+)\s+(?<value>.+)$' ) {
            $currentHostSettings[$Matches["setting"].Trim()] = $Matches["value"].Trim()
        }
    }

    if ( $currentHostName -ne $null ) {
        $sshConfig[$currentHostName] = $currentHostSettings
    }

    $sshConfig
}

function Add-SshConfig() {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string] $SshHost,
        [Parameter(Position = 1, Mandatory = $true)]
        [string] $PrivateKeyPath,
        [Parameter(Position = 2, Mandatory = $false)]
        [string] $SshHostName
    )

    if ( [string]::IsNullOrEmpty($SshHostName) )  {
        $SshHostName = $SshHost
    }

    $sshConfigEntry = @{
        HostName = $SshHostName
        IdentityFile = $PrivateKeyPath
        IdentitiesOnly = "true"
    }

    $sshConfig = Get-SshConfig
    $sshConfig[$SshHost] = $sshConfigEntry

    Set-SshConfig -SshConfig $sshConfig
}

function Set-SshConfig() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [hashtable] $SshConfig
    )

    $sshConfigFilePath = Join-Path $env:USERPROFILE ".ssh\config"

    $finalConfig = @()
    
    foreach ( $sshHost in $sshConfig.Keys ) {
        $finalConfig += ( "Host {0}" -f $sshHost )
        $hostSettings = $sshConfig[$sshHost]
        foreach ( $settingKey in $hostSettings.Keys ) {
            $finalConfig += "`t{0} {1}" -f $settingKey, $hostSettings[$settingKey]
        }
        $finalConfig += ""
    }

    Set-Content -Path $sshConfigFilePath -Value $finalConfig -Force
}

$githubKeys = GenerateSshKey github "craigpaton@gmail.com" -Verbose
Add-SshConfig -SshHost github.com -PrivateKeyPath $githubKeys.Private

$bitbucketKeys = GenerateSshKey bitbucket "craigpaton@gmail.com" -Verbose
Add-SshConfig -SshHost bitbucket.org -PrivateKeyPath $bitbucketKeys.Private

$storageKeys = GenerateSshKey synology "craig" -Verbose
Add-SshConfig -SshHost storage -PrivateKeyPath $storageKeys.Private

Get-Content ( Join-Path $env:USERPROFILE ".ssh\config" )


<#
Host github.com
     HostName github.com
     User git     
     IdentityFile ~/.ssh/github.com
     IdentitiesOnly yes
#>