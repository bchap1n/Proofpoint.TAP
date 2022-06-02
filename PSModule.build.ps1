if ((Get-PSRepository -Name PSGallery).installationpolicy -ne 'Trusted') { Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted }
          
if (-not (Get-Module PowerShellForGitHub -ErrorAction SilentlyContinue)) {
    try {
        Import-Module PowerShellForGitHub -ErrorAction Stop
    } catch {
        Install-Module PowerShellForGitHub -AllowPrerelease -Force -AllowClobber -Repository PSGallery -Scope CurrentUser 
        Import-Module PowerShellForGitHub -ErrorAction Stop
    }
}


if (-not (Get-Module PowerConfig -ErrorAction SilentlyContinue)) {
    try {
        Import-Module PowerConfig -ErrorAction Stop
    } catch {
        Install-Module PowerConfig -AllowPrerelease -Force
        Import-Module PowerConfig -ErrorAction Stop
    }
}
if (-not (Get-Module Press -ErrorAction SilentlyContinue)) {
    try {
        Import-Module Press -ErrorAction Stop
    } catch {
        Install-Module Press -Force
        Import-Module Press -ErrorAction Stop
    }
}

if (-not (Get-Module 'PSFramework' -ErrorAction SilentlyContinue)) {
    try {
        Import-Module 'PSFramework' -ErrorAction Stop
    } catch {
        Install-Module 'PSFramework' -AllowPrerelease -RequiredVersion '1.6.205' -Force -AllowClobber
        Import-Module 'PSFramework' -ErrorAction Stop
    }
}
. Press.Tasks

Task Press.CopyModuleFiles @{
    Inputs  = {
        Get-ChildItem -File -Recurse $PressSetting.General.SrcRootDir
        $SCRIPT:IncludeFiles = (
            $null = (Get-ChildItem -File -Recurse "$($PressSetting.General.SrcRootDir)\somesubfolder") | Resolve-Path 
        )
        $IncludeFiles
    }
    Outputs = {
        $buildItems = Get-ChildItem -File -Recurse $PressSetting.Build.ModuleOutDir
        if ($buildItems) { $buildItems } else { 'EmptyBuildOutputFolder' }
    }
    Jobs    = {
        Remove-BuildItem $PressSetting.Build.ModuleOutDir

        $copyResult = Copy-PressModuleFiles @commonParams `
            -Destination $PressSetting.Build.ModuleOutDir `
            -PSModuleManifest $PressSetting.BuildEnvironment.PSModuleManifest

        $PressSetting.OutputModuleManifest = $copyResult.OutputModuleManifest
    }
}

Task Package Press.Package.Zip

<# Task Press.Test.Pester.WindowsPowershell {
    Write-Warning 'Windows Powershell Tests cannot currently be run due to a bug. Run the tests manually. Remove when https://github.com/pester/Pester/issues/1974 is closed'
} #>

# custom
<# Task buildnupkg -After Press.Default {
    if ( (Test-Path "$($PressSetting.Build.OutDir)\nupkg") -eq $true ) {
        Remove-Item -Path "$($PressSetting.Build.OutDir)\nupkg" -Recurse -Force
    } 
    
    mkdir -Path "$($PressSetting.Build.OutDir)\nupkg" | Out-Null
    New-PressNugetPackage -Path "$($presssetting.BuildEnvironment.PSModuleManifest)" -Destination "$($PressSetting.Build.OutDir)\nupkg"
    #$item = Get-ChildItem "$($PressSetting.Build.OutDir)\nupkg" -Filter *.nupkg
    #Rename-Item -Path $item.FullName -NewName "$($item.name).zip" -Force
} #>
