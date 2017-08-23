# Update path for SSH (Loaded in PowerShell Profile)
if($env:path -notmatch "Git\\bin"){ $env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\bin"}
if($env:path -notmatch "Git\\usr\\bin"){$env:path += ";" + (Get-Item "Env:ProgramFiles").Value + "\Git\usr\bin"}

# Load SSH agent utils
#. (Resolve-Path ~/Documents/WindowsPowershell/ssh-agent-utils.ps1)

# Spoof terminal environment for git color.
$env:TERM = 'cygwin'

# Load posh-git example profile, which will setup a prompt
#. 'C:\tools\poshgit\*-posh-git-*\profile.example.ps1'
Import-Module posh-git
$env:ShowGit = $true
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host($pwd.ProviderPath) -nonewline
    if($env:ShowGit){
        Write-VcsStatus
    }
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}
Start-SshAgent -Quiet


Pop-Location

Add-SshKey