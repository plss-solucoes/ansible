new-vm -Name $Args[0] -MemoryStartupBytes $Args[2] -Generation 2 -Switchname "LAN"
Set-VMProcessor $Args[0] -Count $Args[1]
mkdir "$($Args[3])\hyper-v\$($Args[0])"
#copy "\\192.168.200.201\temp\Ubuntu\ubuntu.vhdx" "F:\hyper-v\$($Args[0])\"
Copy-Item -path "c:\temp\Ubuntu\ubuntu.vhdx" -Destination "$($Args[3])\hyper-v\$($Args[0])"
ren "$($Args[3])\hyper-v\$($Args[0])\ubuntu.vhdx" "$($Args[3])\hyper-v\$($Args[0])\$($Args[0]).vhdx"
add-vmharddiskdrive -vmname $Args[0] -path  "$($Args[3])\hyper-v\$($Args[0])\$($Args[0]).vhdx" 
Set-VMHost -ComputerName $Args[0] -VirtualMachinePath "$($Args[3])\hyper-v\$($Args[0])"
Set-VMFirmware $Args[0] -EnableSecureBoot Off

# Colocando HD pra boot em primeira opcao #
$win10g2 = Get-VMFirmware $Args[0]
$win10g2.bootorder
$hddrive = $win10g2.BootOrder[1]
$pxe = $win10g2.BootOrder[0]
Set-VMFirmware -VMName $Args[0] -BootOrder $hddrive,$pxe

#Iniciando VM
Start-VM -Name $Args[0]

#Aguardando a VM inicializar e obter IP
$strQuit = "Not yet"
Do {
$IP = ( GEt-VM -ComputerName localhost -VMName  $Args[0] | Get-VMNetworkAdapter).IpAddresses[0]
if(!$IP){
$strQuit = Read-Host "Máquina em inicialização"
}
else{
$strQuit ="n"
}
} # End of 'Do'
While ($strQuit -ne "N")
"`n Obteve IP..."

#'Start-Sleep -s 70
