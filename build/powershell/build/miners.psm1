function Global:Get-minerfiles {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Types,
        [Parameter(Mandatory = $false)]
        [string]$Cudas
    )
 
    $miner_update = [PSCustomObject]@{ }

    switch ($Types) {
        "CPU" {
            if ($(arg).Platform -eq "linux") { $(arg).Update = Get-Content ".\config\update\cpu-linux.json" | ConvertFrom-Json }
            elseif ($(arg).Platform -eq "windows") { $(arg).Update = Get-Content ".\config\update\cpu-win.json" | ConvertFrom-Json }
        }

        "NVIDIA" {
            if ($(arg).Platform -eq "linux") {
                if ($Cudas -eq "10") { $(arg).Update = Get-Content ".\config\update\nvidia10-linux.json" | ConvertFrom-Json }
                if ($Cudas -eq "9.2") { $(arg).Update = Get-Content ".\config\update\nvidia9.2-linux.json" | ConvertFrom-Json }
            }
            elseif ($(arg).Platform -eq "windows") { $(arg).Update = Get-Content ".\config\update\nvidia-win.json" | ConvertFrom-Json }
        }

        "AMD" {
            if ($(arg).Platform -eq "linux") { $(arg).Update = Get-Content ".\config\update\amd-linux.json" | ConvertFrom-Json }
            elseif ($(arg).Platform -eq "windows") { $(arg).Update = Get-Content ".\config\update\amd-win.json" | ConvertFrom-Json }
        }
    }

    $(arg).Update | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object { if ($_ -ne "name") { $miner_update | Add-Member $(arg).Update.$_.Name $(arg).Update.$_ } }

    $miner_update

}
