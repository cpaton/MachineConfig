function Test-Admin {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal( $identity )
    return $principal.IsInRole( [System.Security.Principal.WindowsBuiltInRole]::Administrator )
}

function RunScriptAsAdmin() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string] $ScriptPath
    )

    Write-Verbose ( "Running script {0} as administrator" -f $ScriptPath )
    Start-Process powershell -Verb RunAs -ArgumentList ( '-ExecutionPolicy bypass -NoExit -NoProfile -Command "{0}"' -f $ScriptPath )
}