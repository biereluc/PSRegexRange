#Requires -Modules Pester

BeforeDiscovery {
    Remove-Module PSRegexRange -Force -ErrorAction SilentlyContinue
     if (-not (Get-Module -Name PSRegexRange) -or -not (Get-Command -Name ConvertTo-RegexRange -ErrorAction SilentlyContinue)) {
         Import-Module -Name "$PSScriptRoot\..\PSRegexRange.psd1" -Force -Verbose
     }
}
Describe -Name 'Testing ConvertTo-RegexRange Inputs' -Tag 'Unit', 'Inputs', 'ConvertTo-RegexRange' {
    Context -Name 'When a given Min or Max is not a number' -Tag 'Min', 'Max', 'TypeOf', 'Error' {
        It 'should be throw an error' -Test {
            { ConvertTo-RegexRange -Min 'NotANumber' -NoCache } | Should -Throw -Because 'Min should be a number'
        }

        It 'should be throw an error' -Test {
            { ConvertTo-RegexRange -Min 1 -Max 'NotANumber' -NoCache } | Should -Throw -Because 'Max should be a number'
        }
    }

    Context 'Testing parameter positioning' {
        It 'Should accept positional parameters' {
            $result = ConvertTo-RegexRange 1 10
            $result.Result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept named parameters' {
            $result = ConvertTo-RegexRange -Min 1 -Max 10
            $result.Result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept mixed parameters' {
            $result = ConvertTo-RegexRange 1 -Max 10
            $result.Result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe -Name 'Testing ConvertTo-RegexRange Result' -Tag 'Result', 'ConvertTo-RegexRange' {
    $Script:testCases = @(
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
    )

    Context 'When a given Min and Max range is an expected regular expression pattern' -Tag 'Pattern' {
        It -Name 'be able to convert a range to a regex pattern <Expected> for a given range <Min>..<Max>' -TestCases $testCases {
            param($Min, $Max, $Expected)

            $result = ConvertTo-RegexRange -Min $Min -Max $Max -NoCache
            $result.Result | Should -BeExactly $Expected -Because 'The result should be exactly an expected regex pattern'
        }
    }

    Context 'When Min and Max edges are within a given range' -Tag 'Edges' {
        It 'match edges values in range <Min> to <Max>' -TestCases $testCases {
            param($Min, $Max)

            $result = ConvertTo-RegexRange -Min $Min -Max $Max -NoCache
            $pattern = "^($($result.Result))$"
            foreach ($value in $Min, $Max)
            {
                $valueString = $value.ToString()
                $valueString | Should -Match $pattern -Because 'The edge value should be matched by the regex'
            }
        }

        It 'NOT match edges values in range <Min> to <Max>' -Tag 'Edge', 'Error', 'Out-Of-Range' -TestCases $testCases {
            param($Min, $Max)

            $result = ConvertTo-RegexRange -Min $Min -Max $Max -NoCache
            $pattern = "^($($result.Result))$"
            # Out of range values
            foreach ($value in @(($Min - 1), ($Max + 1)))
            {
                $value.ToString() | Should -Not -Match $pattern -Because 'The edge value should not be matched by the regex'
            }
        }
    }

    Context 'When testing all range values are within a given range' -Tag 'All' -Skip:$false {
        It 'match all sequential values in range <Min> to <Max>' -TestCases $testCases {
            param($Min, $Max, $Expected)

            if (($Max - $Min) -gt 5555)
            {
                Write-Host "Skipping test for large range: $Min to $Max" -ForegroundColor Yellow
                Set-ItResult -Skipped -Because "Skipping test for large range: $Min to $Max"
                return
            }
            $result = ConvertTo-RegexRange -Min $Min -Max $Max -NoCache
            $pattern = "^($($result.Result))$"
            foreach ($value in $Min..$Max)
            {
                $value.ToString() | Should -Match $pattern -Because 'The value should be matched by the regex pattern'
            }
        }
    }

    Context 'When a random value are within a given range' -Tag 'Random' {
        It 'match a random value in range <Min> to <Max>' -TestCases $testCases {
            param($Min, $Max)

            function Get-RandomNumber($Min, $Max)
            {
                if ($Min -eq $Max) { return $Min }
                return Get-Random -Minimum $Min -Maximum $Max
            }
            $result = ConvertTo-RegexRange -Min $Min -Max $Max -NoCache
            $pattern = "^($($result.Result))$"
            $value = Get-RandomNumber -Min $Min -Max $Max
            $value.ToString() | Should -Match $pattern -Because 'The random value should be within the range'
        }

        It 'NOT match a random outside range value in range <Min> to <Max>' -TestCases $testCases {
            param($Min, $Max)

            function Get-RandomOutsideRange ($Min, $Max)
            {
                $OutsideRange = Get-Random -Minimum 1
                if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { Get-Random -Minimum ($Min - $OutsideRange) -Maximum $Min }
                else { Get-Random -Minimum ($Max + 1) -Maximum ($Max + $OutsideRange + 1) }
            }
            $result = ConvertTo-RegexRange -Min $Min -Max $Max -NoCache
            $pattern = "^($($result.Result))$"
            $value = Get-RandomOutsideRange -Min $Min -Max $Max
            $value.ToString() | Should -Not -Match $pattern -Because 'The random value should be outside the range'
        }
    }
}