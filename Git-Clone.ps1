$gitRoot = "C:\_cp\Git"

if ( -not ( Test-Path $gitRoot ) ) {
    New-Item -Path $gitRoot -ItemType Directory | Out-Null
}

git clone git@github.com:cpaton/MachineConfig.git C:\_cp\Git\MachineConfig