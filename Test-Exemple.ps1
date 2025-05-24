# Importer la fonction
. $PSScriptRoot\Public\convertto-regexrange.ps1
# ! Temporary
Get-ChildItem -Path '.\Private\*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path .\Public\Write-RegexRangeColorized.ps1 | ForEach-Object { . $_.FullName }
Get-ChildItem -Path .\Public\Test-InRegexRange.ps1 | ForEach-Object { . $_.FullName }



$testCases = @(
            @{ Min = -10; Max = 10; Expected = "-[1-9]|-?10|[0-9]" }
            @{ Min = -100; Max = -10; Expected = "-1[0-9]|-[2-9][0-9]|-100" }
        @{ Min = -100; Max = 100; Expected = "-[1-9]|-?[1-9][0-9]|-?100|[0-9]" }
            @{ Min = '001'; Max = 100; Expected = '0{0,2}[1-9]|0?[1-9][0-9]|100' }
            @{ Min = '001'; Max = 555; Expected = '0{0,2}[1-9]|0?[1-9][0-9]|[1-4][0-9]{2}|5[0-4][0-9]|55[0-5]' }
            @{ Min = '0010'; Max = 1000; Expected = '0{0,2}1[0-9]|0{0,2}[2-9][0-9]|0?[1-9][0-9]{2}|1000' }
            @{ Min = 1; Max = 50; Expected = "[1-9]|[1-4][0-9]|50" }
            @{ Min = 1; Max = 55; Expected = "[1-9]|[1-4][0-9]|5[0-5]" }
            @{ Min = 1; Max = 555; Expected = "[1-9]|[1-9][0-9]|[1-4][0-9]{2}|5[0-4][0-9]|55[0-5]" }
            @{ Min = 1; Max = 5555; Expected = '[1-9]|[1-9][0-9]{1,2}|[1-4][0-9]{3}|5[0-4][0-9]{2}|55[0-4][0-9]|555[0-5]' }
            @{ Min = 111; Max = 555; Expected = "11[1-9]|1[2-9][0-9]|[2-4][0-9]{2}|5[0-4][0-9]|55[0-5]" }
            @{ Min = 29; Max = 51; Expected = "29|[34][0-9]|5[01]" }
            @{ Min = 31; Max = 877; Expected = "3[1-9]|[4-9][0-9]|[1-7][0-9]{2}|8[0-6][0-9]|87[0-7]" }
            @{ Min = 5; Max = 5; Expected = "5" }
            @{ Min = 5; Max = 6; Expected = "5|6" }
            @{ Min = 1; Max = 2; Expected = "1|2" }
            @{ Min = 1; Max = 5; Expected = "[1-5]" }
            @{ Min = 1; Max = 10; Expected = "[1-9]|10" }
            @{ Min = 1; Max = 100; Expected = "[1-9]|[1-9][0-9]|100" }
            @{ Min = 1; Max = 1000; Expected = "[1-9]|[1-9][0-9]{1,2}|1000" }
            @{ Min = 1; Max = 10000; Expected = "[1-9]|[1-9][0-9]{1,3}|10000" }
            @{ Min = 1; Max = 100000; Expected = "[1-9]|[1-9][0-9]{1,4}|100000" }
            @{ Min = 1; Max = 1000000; Expected = "[1-9]|[1-9][0-9]{1,5}|1000000" }
            @{ Min = 1; Max = 10000000; Expected = "[1-9]|[1-9][0-9]{1,6}|10000000" }
        )
foreach ($testCase in $testCases) {
    "$(ConvertTo-RegexRange -Min $testCase.Min -Max $testCase.Max) : $($testCase.Expected)"
}


# # Fonction pour mesurer le temps d'exécution
# function Measure-ExecutionTime
# {
#     param($ScriptBlock)
#     $timer = [System.Diagnostics.Stopwatch]::StartNew()
#     $result = & $ScriptBlock
#     $timer.Stop()
#     return @{
#         Result = $result
#         Time   = $timer.Elapsed.TotalMilliseconds
#     }
# }

# # Fonction pour formater une plage
# function Format-Range
# {
#     param($min, $max)
#     #$options = @{ shorthand = $true }

#     $execution = Measure-ExecutionTime {
#         ConvertTo-RegexRange -Min $min -Max $max
#     }

#     return [PSCustomObject]@{
#         Range  = "$min..$max"
#         Result = $execution.Result.Result
#         Time   = "$([math]::Round($execution.Time, 2)) ms"
#     }
# }


# # Liste des exemples à tester
# $examples = @(
#     @(-10, 10),
#     @(-100, -10),
#     @(-100, 100), #############
#     @(1, 100),
#     @(1, 555),
#     @(10, 1000),
#     @(1, 50),
#     @(1, 55),
#     @(111, 555),
#     @(29, 51),
#     @(31, 877),
#     @(5, 5),
#     @(5, 6),
#     @(1, 2),
#     @(1, 5),
#     @(1, 10),
#     @(1, 100),
#     @(1, 1000),
#     @(1, 10000),
#     @(1, 100000),
#     @(1, 1000000),
#     @(1, 10000000)
# )

# # Générer les résultats
# foreach ($example in $examples)
# {
#     #(ConvertTo-RegexRange -Min $example[0] -Max $example[1] -Capture).Result
#     Format-Range $example[0] $example[1]
# }

# foreach ($example in $examples)
# {
#     $regex = ConvertTo-RegexRange -Min $example[0] -Max $example[1] -Capture
#     Write-Host "Min : $($example[0]) - Max : $($example[1])"
#     Write-Host "Regex : $($regex.Result)"
#     Write-RegexRangeColorized -Min $example[0] -Max $example[1] -Regex $regex.Result -Wait
#     #ConvertTo-RegexRange -Min $example[0] -Max $example[1] -Capture | Write-RegexRangeColorized -Wait
# }




# # # ! Temporary
# # Get-ChildItem -Path '.\Private\*.ps1' | ForEach-Object { . $_.FullName }
# # Get-ChildItem -Path .\Public\Write-RegexRangeColorized.ps1 | ForEach-Object { . $_.FullName }
# # Get-ChildItem -Path .\Public\Test-RegexRange.ps1 | ForEach-Object { . $_.FullName }

# # $Min = 1058
# # $Max = 16985


# # # (ConvertTo-RegexRange -Min 0 -Capture)

# # # ConvertTo-RegexRange -Min 1 -Capture
# # # ConvertTo-RegexRange -Min 1 -Max 1 -Capture
# # ConvertTo-RegexRange -Min -11 -Max 10 -Capture
# # ConvertTo-RegexRange -Min -1 -Max 1 -Capture # a tester
# # ConvertTo-RegexRange -Min 1 -Max 2 -Capture
# # ConvertTo-RegexRange -Min 1 -Max 3 -Capture
# # ConvertTo-RegexRange -Min 10 -Max 1 -Capture


# # ConvertTo-RegexRange -Min 1000000
# # ConvertTo-RegexRange -Min 10 -Max 1000000
# # ConvertTo-RegexRange -Min 1000000 -Max 10


# # try
# # {
# #     ConvertTo-RegexRange -Min 10 -Max 1000000 | Test-InRegexRange -Number 100001
# #     ConvertTo-RegexRange -Min 100000 | Write-RegexRangeColorized -Wait
# #     Pause
# #     ConvertTo-RegexRange -Min $Min -Max $Max -Options @{ RelaxZeros = $true; Shorthand = $true; }
# #     ConvertTo-RegexRange -Min $Min -Max $Max -RelaxZeros | Write-RegexRangeColorized -Wait
# #     ConvertTo-RegexRange -Min 10 -Max 16 | Write-RegexRangeColorized -Wait
# #     Pause



# #     #! Test
# #     0..100 | ForEach-Object {
# #         $max = Get-Random -Maximum 1000 -Minimum 1
# #         $min = Get-Random -Maximum $max -Minimum 0
# #         ConvertTo-RegexRange -Min $Min -Max $Max -RelaxZeros | Write-RegexRangeColorized -Wait -Boundary 2
# #     }
# # }
# # catch
# # {
# #     Write-Error $_
# #     Pause
# # }