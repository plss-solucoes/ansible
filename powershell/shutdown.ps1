# Shutdown VMs 
Get-VM -ComputerName $Args[0] 
    Sort-Object -Property AutomaticStartDelay -Descending | ` 
    ForEach-Object { 
        $_ | Stop-VM 
        Start-Sleep -Seconds $TimeToWait 
    }