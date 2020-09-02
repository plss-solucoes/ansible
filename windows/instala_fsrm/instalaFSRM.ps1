## Intala e configura FSRM por PowerShell - Rudi - PLSS ###

​

### Arquivo precisa ficar na pasta C:\temp e com o nome de instalaFSRM.ps1

### É necessário habilitar script em powershell com o comando: Set-ExecutionPolicy unrestricted -Confirm:$false -Force

​

​

#Verifica se função FSRM já está instalada

if (Get-WindowsFeature -Name  FS-resource-manager | Where-Object {$_.Installed -match "True"})

    {

        #cria o grupo 

        new-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -UseBasicParsing -Uri "https://fsrm.experiant.ca/api/v1/get").content | convertfrom-json | % {$_.filters})

        #Cria modelo de triagem e seta pastas e unidades

        New-FsrmFileScreenTemplate -name "Bloquear Arquivos Ransomware" -IncludeGroup "Arquivos Ransomware"

        cd c:\

        mkdir FSRM

        echo 'set-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -UseBasicParsing -Uri "https://fsrm.experiant.ca/api/v1/get").content | convertfrom-json | % {$_.filters})' > C:\FSRM\AtualizarListaFSRMRansomware.ps1

        $pastasC=Get-ChildItem -Name -Directory -Exclude "windows"

        $pastasC | foreach {New-FsrmFileScreen -Path "C:\$_" -IncludeGroup "Arquivos Ransomware"}

        $drive=Get-CimInstance -Query "select * from Win32_LogicalDisk where deviceid <> 'C:' and drivetype = '3'" | foreach-object {$_.deviceid} 

        $drive | foreach {New-FsrmFileScreen -Path "$_\" -IncludeGroup "Arquivos Ransomware"} 

        #Cria tarefa agendada para atualizar lista diareiamente as 11pm

        $argumento="-File C:\FSRM\AtualizarListaFSRMRansomware.ps1 -ExecutionPolicy Bypass"

        $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $argumento

        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        $trigger = New-ScheduledTaskTrigger -Daily -At 11pm

        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger

        Register-ScheduledTask "Atualiza Lista Ransomware" -InputObject $task -Force

        #testa pra ver se tem a tarefa para executar novamente o arquivo, caso sim remove.

        if (Get-ScheduledTask -TaskName "Instala FSRM")

            {

                Unregister-ScheduledTask -TaskName "Instala FSRM" -Confirm:$false

            }

         else{$naoR="ok"}

​

    }

    

   

#Se função FSRM NÃO estiver instalada ele irá instalar, antes cria uma tarefa para executar o arquivo novamente

else #(Get-WindowsFeature -Name FS-resource-manager| Where-Object {$_.Installed -match "False"}) 

    {

        #cria a tarefa para executar após reiniciar e instala o FSRM

        $argumentoR="-File C:\temp\instalaFSRM.ps1 -ExecutionPolicy Bypass"

        $actionR = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $argumentoR

        $principalR = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        $triggerR = New-ScheduledTaskTrigger -AtStartup

        $taskR = New-ScheduledTask -Action $actionR -Principal $principalR -Trigger $triggerR

        Register-ScheduledTask "Instala FSRM" -InputObject $taskR -Force

        Install-WindowsFeature -Name FS-resource-manager -IncludeManagementTools -Restart

        $exec=new-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -UseBasicParsing -Uri "https://fsrm.experiant.ca/api/v1/get").content | convertfrom-json | % {$_.filters})

        #Testa a criação do Grupo - se SIM cria modelo de triagem e seta pastas e unidades

        if ($exec)

            {

                New-FsrmFileScreenTemplate -name "Bloquear Arquivos Ransomware" -IncludeGroup "Arquivos Ransomware"

                cd c:\

                mkdir FSRM

                echo 'set-FsrmFileGroup -name "Arquivos Ransomware" -IncludePattern @((Invoke-WebRequest -UseBasicParsing -Uri "https://fsrm.experiant.ca/api/v1/get").content | convertfrom-json | % {$_.filters})' > AtualizarListaFSRMRansomware.ps1

                $pastasC=Get-ChildItem -Name -Directory -Exclude "windows"

                $pastasC | foreach {New-FsrmFileScreen -Path "C:\$_" -IncludeGroup "Arquivos Ransomware"}

                $drive=Get-CimInstance -Query "select * from Win32_LogicalDisk where deviceid <> 'C:' and drivetype = '3'" | foreach-object {$_.deviceid} 

                $drive | foreach {New-FsrmFileScreen -Path "$_\" -IncludeGroup "Arquivos Ransomware"} 

                #Cria tarefa agendada para atualizar lista diareiamente as 11pm

                $argumento="-File C:\FSRM\AtualizarListaFSRMRansomware.ps1 -ExecutionPolicy Bypass"

                $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument $argumento

                $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

                $trigger = New-ScheduledTaskTrigger -Daily -At 11pm

                $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger

                Register-ScheduledTask "Atualiza Lista Ransomware" -InputObject $task -Force

                #apaga tarefa para executar o script caso reinicia-se

                if (Get-ScheduledTask -TaskName "Instala FSRM")

                    {

                        Unregister-ScheduledTask -TaskName "Instala FSRM" -Confirm:$false

                    }

                else {$naoR="ok"}

            }

        #Se Não Reincia o computador, pois em alguns casos de Windows 2012 é necessário a segunda reinicialização após a instalação da função FSRM

        else {Restart-Computer}

    }