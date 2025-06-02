Describe 'ConvertTo-RegexRange' {
    BeforeAll {
        Remove-Module Pester -Force
        Install-Module -Name Pester -Force -SkipPublisherCheck -RequiredVersion 5.5.0
        Import-Module Pester -Force -PassThru
        $rootPath = Split-Path -Path $PSScriptRoot -Parent
        $Public = @( Get-ChildItem -Path "$rootPath\Public\*.ps1" -ErrorAction SilentlyContinue )
        $Private = @( Get-ChildItem -Path "$rootPath\Private\*.ps1" -ErrorAction SilentlyContinue )

        foreach ($file in @($Public + $Private))
        {
            try
            {
                . $file.FullName
                Write-Verbose "Imported: $($file.Name)"
            }
            catch
            {
                Write-Error "Failed to import $($file.FullName): $_"
            }
        }
    }

    Context 'Test range to regex conversion' {
        $testCases = @(
            @{ Min = -10; Max = 10; Expected = '-[1-9]|-?10|[0-9]' }
            @{ Min = -100; Max = -10; Expected = '-1[0-9]|-[2-9][0-9]|-100' }
            @{ Min = -100; Max = 100; Expected = '-[1-9]|-?[1-9][0-9]|-?100|[0-9]' }
            @{ Min = '001'; Max = 100; Expected = '0{0,2}[1-9]|0?[1-9][0-9]|100' }
            @{ Min = '001'; Max = 555; Expected = '0{0,2}[1-9]|0?[1-9][0-9]|[1-4][0-9]{2}|5[0-4][0-9]|55[0-5]' }
            @{ Min = '0010'; Max = 1000; Expected = '0{0,2}1[0-9]|0{0,2}[2-9][0-9]|0?[1-9][0-9]{2}|1000' }
            @{ Min = 1; Max = 50; Expected = '[1-9]|[1-4][0-9]|50' }
            @{ Min = 1; Max = 55; Expected = '[1-9]|[1-4][0-9]|5[0-5]' }
            @{ Min = 1; Max = 555; Expected = '[1-9]|[1-9][0-9]|[1-4][0-9]{2}|5[0-4][0-9]|55[0-5]' }
            @{ Min = 1; Max = 5555; Expected = '[1-9]|[1-9][0-9]{1,2}|[1-4][0-9]{3}|5[0-4][0-9]{2}|55[0-4][0-9]|555[0-5]' }
            @{ Min = 111; Max = 555; Expected = '11[1-9]|1[2-9][0-9]|[2-4][0-9]{2}|5[0-4][0-9]|55[0-5]' }
            @{ Min = 29; Max = 51; Expected = '29|[34][0-9]|5[01]' }
            @{ Min = 31; Max = 877; Expected = '3[1-9]|[4-9][0-9]|[1-7][0-9]{2}|8[0-6][0-9]|87[0-7]' }
            @{ Min = 5; Max = 5; Expected = '5' }
            @{ Min = 5; Max = 6; Expected = '5|6' }
            @{ Min = 1; Max = 2; Expected = '1|2' }
            @{ Min = 1; Max = 5; Expected = '[1-5]' }
            @{ Min = 1; Max = 10; Expected = '[1-9]|10' }
            @{ Min = 1; Max = 100; Expected = '[1-9]|[1-9][0-9]|100' }
            @{ Min = 1; Max = 1000; Expected = '[1-9]|[1-9][0-9]{1,2}|1000' }
            @{ Min = 1; Max = 10000; Expected = '[1-9]|[1-9][0-9]{1,3}|10000' }
            @{ Min = 1; Max = 100000; Expected = '[1-9]|[1-9][0-9]{1,4}|100000' }
            @{ Min = 1; Max = 1000000; Expected = '[1-9]|[1-9][0-9]{1,5}|1000000' }
            @{ Min = 1; Max = 10000000; Expected = '[1-9]|[1-9][0-9]{1,6}|10000000' }
            #! @{ Min = 0; Max = 11; Expected = '[error]' }
        )

        It 'Should be able to convert a range to a regex pattern for a given range <Min>..<Max>' -TestCases $testCases {
            param($Min, $Max, $Expected)

            $result = ConvertTo-RegexRange -Min $Min -Max $Max
            $result.Result | Should -Be $Expected
        }
    }
}
