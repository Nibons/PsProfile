Write-Information "Starting PowerShell Profile"

if ($pwd.path -eq "$($env:SystemRoot)\system32") {Set-Location $HOME}
$HPSCredential = import-clixml $home\HPSCredential.xml

Start-Transcript -path "$(split-path -parent $profile)\Transcripts\PowerShell_$(get-date -format 'yyyy.mm.dd').log" -append
function prompt {"[$(get-date -format 'HH:mm:ss')] [{0}]>" -f $PWD.Path}

. "$psscriptRoot\Docker_Profile.ps1"


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