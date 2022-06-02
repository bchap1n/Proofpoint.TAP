#requires -Modules BuildHelpers
#requires -Modules @{ModuleName='Pester';ModuleVersion='5.1.1'}
Describe 'proofpoint.tap' {
    BeforeAll {
        $SCRIPT:Mocks = Resolve-Path $PSScriptRoot/Mocks
        Write-Verbose 'Loading Module to Test'
        #TODO: Remove Press Hardcoding
        $PathToScript = if ( $PSScriptRoot ) { $PSScriptRoot } else { Split-Path $psEditor.GetEditorContext().CurrentFile.Path }
        $repoPath = (Get-Item $PathToScript).parent.parent
        
        Import-Module $repoPath/Proofpoint.TAP/proofpoint.tap.psd1 -Force -Global 4>$null
        function JsonMock ($Path) {
            Get-Content -Raw (Join-Path $SCRIPT:Mocks $Path) | ConvertFrom-Json
        }
    }
    AfterAll {
        Write-Verbose 'Loading out Module to Test'
        Import-Module $repoPath/BuildOutput/Proofpoint.TAP/proofpoint.tap.psm1 -Force -Global 4>$null
    }

    BeforeEach {
       
    }

    It 'Command is present after module import' {
        $Commands = Get-Command -Module 'Proofpoint.TAP' 
        'Get-TapClickersbyLookbackDays' | Should -BeIn $Commands.Name
        #'Get-TAPclickers1hour' | Should -BeIn $Commands.Name
    }

    

    
}