$gitRoot = "C:\_cp\Git"

if ( -not ( Test-Path $gitRoot ) ) {
    New-Item -Path $gitRoot -ItemType Directory | Out-Null
}

& 'C:\Program Files\Git\bin\git' clone git@github.com:cpaton/MachineConfig.git C:\_cp\Git\MachineConfig
& 'C:\Program Files\Git\bin\git' clone ssh://Craig@storage:60022/volume1/Data/Git/Repos/Documents c:\_cp\Documents