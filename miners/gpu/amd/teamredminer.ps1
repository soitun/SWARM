$AMDTypes | ForEach-Object {
    
    $ConfigType = $_; $Num = $ConfigType -replace "AMD", ""

    ##Miner Path Information
    if ($amd.teamredminer.$ConfigType) { $Path = "$($amd.teamredminer.$ConfigType)" }
    else { $Path = "None" }
    if ($amd.teamredminer.uri) { $Uri = "$($amd.teamredminer.uri)" }
    else { $Uri = "None" }
    if ($amd.teamredminer.minername) { $MinerName = "$($amd.teamredminer.minername)" }
    else { $MinerName = "None" }

    $User = "User$Num"; $Pass = "Pass$Num"; $Name = "teamredminer-$Num"; $Port = "2800$Num"

    Switch ($Num) {
        1 { $Get_Devices = $AMDDevices1 }
    }

    ##Log Directory
    $Log = Join-Path $($global:Dir) "logs\$ConfigType.log"

    ##Parse -GPUDevices
    if ($Get_Devices -ne "none") { $Devices = $Get_Devices }
    else { $Devices = $Get_Devices }

    ##Get Configuration File
    $MinerConfig = $Global:config.miners.teamredminer

    ##Export would be /path/to/[SWARMVERSION]/build/export##
    $ExportDir = Join-Path $($global:Dir) "build\export"

    ##Prestart actions before miner launch
    $BE = "/usr/lib/x86_64-linux-gnu/libcurl-compat.so.3.0.0"
    $Prestart = @()
    $PreStart += "export LD_LIBRARY_PATH=$ExportDir"
    $MinerConfig.$ConfigType.prestart | ForEach-Object { $Prestart += "$($_)" }

    if ($Coins -eq $true) { $Pools = $CoinPools }else { $Pools = $AlgoPools }

    ##Build Miner Settings
    $MinerConfig.$ConfigType.commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {

        $MinerAlgo = $_

        if ($MinerAlgo -in $Algorithm -and $Name -notin $global:Exclusions.$MinerAlgo.exclusions -and $ConfigType -notin $global:Exclusions.$MinerAlgo.exclusions -and $Name -notin $global:banhammer) {
            $Stat = Get-Stat -Name "$($Name)_$($MinerAlgo)_hashrate"
            $Check = $Global:Miner_HashTable | Where Miner -eq $Name | Where Algo -eq $MinerAlgo | Where Type -Eq $ConfigType
        
            if ($Check.RAW -ne "Bad") {
                $Pools | Where-Object Algorithm -eq $MinerAlgo | ForEach-Object {
                    if ($MinerConfig.$ConfigType.difficulty.$($_.Algorithm)) { $Diff = ",d=$($MinerConfig.$ConfigType.difficulty.$($_.Algorithm))" }else { $Diff = "" }
                    [PSCustomObject]@{
                        MName      = $Name
                        Coin       = $Coins
                        Delay      = $MinerConfig.$ConfigType.delay
                        Fees       = $MinerConfig.$ConfigType.fee.$($_.Algorithm)
                        Symbol     = "$($_.Symbol)"
                        MinerName  = $MinerName
                        Prestart   = $PreStart
                        Type       = $ConfigType
                        Path       = $Path
                        Devices    = $Devices
                        DeviceCall = "tdxminer"
                        Arguments  = "--platform $AMDPlatform -a $($MinerConfig.$ConfigType.naming.$($_.Algorithm)) --api_listen=0.0.0.0:$Port -o stratum+tcp://$($_.Host):$($_.Port) -u $($_.$User) --log_file `'$Log`' -p $($_.$Pass)$($DIff) $($MinerConfig.$ConfigType.commands.$($_.Algorithm))"
                        HashRates  = [PSCustomObject]@{$($_.Algorithm) = $Stat.Hour}
                        Quote      = if ($Stat.Hour) { $Stat.Hour * ($_.Price) }else { 0 }
                        PowerX     = [PSCustomObject]@{$($_.Algorithm) = if ($Watts.$($_.Algorithm)."$($ConfigType)_Watts") { $Watts.$($_.Algorithm)."$($ConfigType)_Watts" }elseif ($Watts.default."$($ConfigType)_Watts") { $Watts.default."$($ConfigType)_Watts" }else { 0 } }
                        MinerPool  = "$($_.Name)"
                        FullName   = "$($_.Mining)"
                        Port       = $Port 
                        API        = "sgminer-gm"
                        Wallet     = "$($_.$User)"
                        URI        = $Uri
                        Server     = "localhost"
                        Algo       = "$($_.Algorithm)"                         
                        Log        = "miner_generated"
                    }
                }
            }
        }
    }
}
