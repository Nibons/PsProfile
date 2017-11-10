$cPackage = "git
openssh
visualstudiocode
displayfusion
rdcman
putty
resilio-sync-home
" -split "`r`n"

$vsCodeConfigInit = @'
{"sync.gist": 
"688c0c19d76e6398751babec3f426b1f"}
'@


configuration installStuff{
    Param($cPackage,$vsCodeConfigInit)
    import-dscResource -name cChocoInstaller,cChocoPackageInstallerSet 
    Node Localhost {
        cChocoInstaller installChoco {
            InstallDir = "$($env:ProgramFiles)"
        }

        cChocoPackageInstallerSet PackageSet1 {
            Name = $cPackage
            Ensure = 'Present'
        }

        File vsCodeSettingsInit {
            DestinationPath = "c:\Users\Clay.Haertzen\AppData\Roaming\Code\User\settings.json"
            Contents = $vsCodeConfigInit
        }
    }
}

installStuff -cPackage $cPackage -vsCodeConfigInit $vsCodeConfigInit -OutputPath .
Start-DscConfiguration -Wait -force -verbose -Path . 