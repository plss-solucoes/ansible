$runningVM = Get-VM -ComputerName $Args[0]| where  state -eq 'running'
Do { foreach ($cn in $runningVM)  
{Stop-VM $cn.name -asjob} } 
$status = (Get-VM $cn).PowerState } 
Until ($status -eq "stopped") Start-Sleep -Seconds 15 Write-Host "$($cn) has shutdown. It should be ready for configuration."

Else { Write-Host "VM '$($vmName)' is not powered on!" } } 
Else { Write-Host "VM '$($vmName)' not found!" }

### BEGIN ELEVEATE TO ADMIN

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   #$Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
### END ELEVATE TO ADMIN

import-module hyper-v

#Compact All VM HD's Where the VM is Off
$VMsThatAreOff = Get-VM | ?{$_.State -eq "Off"}
$VMsThatAreOn = Get-VM | ?{$_.State -eq "Running"}
$VMHDs = @()

Write-Host "As seguintes máquinas virtuais estavam desligadas e puderam ser compactadas."
write-host ""
foreach($VM in $VMsThatAreOff)
{
    $Vm.Name
}
foreach ($VM in $VMsThatAreOff)
    {
        $VMHDs += $VM | Get-VMHardDiskDrive
    }
foreach ($HD in $VMHDs)
    {
        Optimize-VHD $HD.Path
        
    }
   
get-vm  | start-vm
remove-module hyper-v
