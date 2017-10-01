Write-Information "Starting PowerShell Profile"
#$env:docker_host = 'tcp://nanocontainers:2375'
if ($pwd.path -eq "$($env:SystemRoot)\system32") {Set-Location $HOME}
#$HBEcredential = get-credential -Message "chfs\clay.haertzen Credentials"
function prompt {"[$(get-date -format 'HH:mm:ss')] [{0}]>" -f $PWD.Path}
$servername_ProdDeploy = "HFSNE121-037436.chfs.ds.ky.gov"
$hbeCredential = Import-Clixml -Path "$home\HBECredential.xml"
$dockerCredential = import-clixml -path "$home\dockerCredential.xml"

if (Test-Connection -ComputerName $servername_ProdDeploy -Count 1 -Quiet) {
    if (!(test-path e:\) -and !(get-psdrive | Where-Object name -eq 'E')) {New-PSDrive -Name E -PSProvider FileSystem -Root "\\$servername_ProdDeploy\e$" -Credential $hbeCredential} 
    if (!(get-psdrive | Where-Object name -eq 'scripts')) {new-psdrive -Name Scripts -PSProvider FileSystem -Root "\\$servername_ProdDeploy\scripts" -Credential $hbeCredential| Out-Null}
    Import-Module Scripts:\Get-Servers.psm1
}
#set CredSSP to enabled

Function switch-ContainerOSArch {
    & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon
}

#region GIT
if (Test-Path Function:\Prompt) {Rename-Item Function:\Prompt PrePoshGitPrompt -Force}
# Load posh-git example profile
. "$psscriptRoot\setup_GIT.ps1"

Rename-Item Function:\Prompt PoshGitPrompt -Force
function Prompt() {
    if (Test-Path Function:\PrePoshGitPrompt) {
        ++$global:poshScope
        New-Item function:\script:Write-host -value "param([object] `$object, `$backgroundColor, `$foregroundColor, [switch] `$nonewline)" -Force | Out-Null
        $private:p = PrePoshGitPrompt
        if (--$global:poshScope -eq 0) {
            Remove-Item function:\Write-Host -Force
        }
    }
    PoshGitPrompt
}


#endregion

#clear-host