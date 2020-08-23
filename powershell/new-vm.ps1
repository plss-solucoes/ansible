new-vm -Name $Args[0] -MemoryStartupBytes $Args[2] -Generation 2 -NewVHDPath "F:\hyper-v\$($Args[0])\$($Args[0]).vhdx" -NewVHDSizeBytes 30000000000 -Switchname "LAN"
Set-VMProcessor $Args[0] -Count $Args[1]
Set-VMHost -ComputerName $Args[0] -VirtualMachinePath "F:\hyper-v\$($Args[0])"
