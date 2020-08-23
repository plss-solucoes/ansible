Install-WindowsFeature –Name FS-Resource-Manager –IncludeManagementTools -Restart
#Cria Lista - Caso de ok segue senão reinicia maquina pois precisa da segunda reinicialização
$exec=new-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -UseBasicParsing -Uri "https://fsrm.experiant.ca/api/v1/get").content | convertfrom-json | % {$_.filters})
if ($exec)
{}
else {Restart-Computer}