# Importer la fonction
. $PSScriptRoot\Public\convertto-regexrange.ps1
# ! Temporary
Get-ChildItem -Path '.\Private\*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path .\Public\Write-RegexRangeColorized.ps1 | ForEach-Object { . $_.FullName }
Get-ChildItem -Path .\Public\Test-InRegexRange.ps1 | ForEach-Object { . $_.FullName }

# Fonction pour mesurer le temps d'exécution
function Measure-ExecutionTime
{
    param($ScriptBlock)
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $result = & $ScriptBlock
    $timer.Stop()
    return @{
        Result = $result
        Time   = $timer.Elapsed.TotalMilliseconds
    }
}

# Fonction pour formater une plage
function Format-Range
{
    param($min, $max)
    #$options = @{ shorthand = $true }

    $execution = Measure-ExecutionTime {
        ConvertTo-RegexRange -Min $min -Max $max
    }

    return [PSCustomObject]@{
        Range  = "$min..$max"
        Result = $execution.Result.Result
        Time   = "$([math]::Round($execution.Time, 2)) ms"
    }
}


# Liste des exemples à tester
$examples = @(
    @(-10, 10),
    @(-100, -10),
    @(-100, 100), #############
    @(1, 100),
    @(1, 555),
    @(10, 1000),
    @(1, 50),
    @(1, 55),
    @(111, 555),
    @(29, 51),
    @(31, 877),
    @(5, 5),
    @(5, 6),
    @(1, 2),
    @(1, 5),
    @(1, 10),
    @(1, 100),
    @(1, 1000),
    @(1, 10000),
    @(1, 100000),
    @(1, 1000000),
    @(1, 10000000)
)

# Générer les résultats
foreach ($example in $examples)
{
    #(ConvertTo-RegexRange -Min $example[0] -Max $example[1] -Capture).Result
    Format-Range $example[0] $example[1]
}

foreach ($example in $examples)
{
    $regex = ConvertTo-RegexRange -Min $example[0] -Max $example[1] -Capture
    Write-Host "Min : $($example[0]) - Max : $($example[1])"
    Write-Host "Regex : $($regex.Result)"
    Write-RegexRangeColorized -Min $example[0] -Max $example[1] -Regex $regex.Result -Wait
    #ConvertTo-RegexRange -Min $example[0] -Max $example[1] -Capture | Write-RegexRangeColorized -Wait
}




# # ! Temporary
# Get-ChildItem -Path '.\Private\*.ps1' | ForEach-Object { . $_.FullName }
# Get-ChildItem -Path .\Public\Write-RegexRangeColorized.ps1 | ForEach-Object { . $_.FullName }
# Get-ChildItem -Path .\Public\Test-RegexRange.ps1 | ForEach-Object { . $_.FullName }

# $Min = 1058
# $Max = 16985


# # (ConvertTo-RegexRange -Min 0 -Capture)

# # ConvertTo-RegexRange -Min 1 -Capture
# # ConvertTo-RegexRange -Min 1 -Max 1 -Capture
# ConvertTo-RegexRange -Min -11 -Max 10 -Capture
# ConvertTo-RegexRange -Min -1 -Max 1 -Capture # a tester
# ConvertTo-RegexRange -Min 1 -Max 2 -Capture
# ConvertTo-RegexRange -Min 1 -Max 3 -Capture
# ConvertTo-RegexRange -Min 10 -Max 1 -Capture


# ConvertTo-RegexRange -Min 1000000
# ConvertTo-RegexRange -Min 10 -Max 1000000
# ConvertTo-RegexRange -Min 1000000 -Max 10


# try
# {
#     ConvertTo-RegexRange -Min 10 -Max 1000000 | Test-InRegexRange -Number 100001
#     ConvertTo-RegexRange -Min 100000 | Write-RegexRangeColorized -Wait
#     Pause
#     ConvertTo-RegexRange -Min $Min -Max $Max -Options @{ RelaxZeros = $true; Shorthand = $true; }
#     ConvertTo-RegexRange -Min $Min -Max $Max -RelaxZeros | Write-RegexRangeColorized -Wait
#     ConvertTo-RegexRange -Min 10 -Max 16 | Write-RegexRangeColorized -Wait
#     Pause



#     #! Test
#     0..100 | ForEach-Object {
#         $max = Get-Random -Maximum 1000 -Minimum 1
#         $min = Get-Random -Maximum $max -Minimum 0
#         ConvertTo-RegexRange -Min $Min -Max $Max -RelaxZeros | Write-RegexRangeColorized -Wait -Boundary 2
#     }
# }
# catch
# {
#     Write-Error $_
#     Pause
# }