function ConvertTo-RegexRange
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Min,
        [Parameter(Mandatory)]
        [string]$Max,
        [hashtable]$Options = @{
            RelaxZeros = $true
            Shorthand  = $false
            Capture    = $false
            Wrap       = $true
        }
    )

    #TODO isNumber min et max, car pour avoir le padding zero, il faut que le min et max soit un string ex.: 01 0123

    #$key = "$min`:$max=$($Options.RelaxZeros)$($Options.Shorthand)$($Options.Capture)$($Options.Wrap)"

    #TODO get-content $tmpfile
    #if ($Global:RegexRange -and $Global:RegexRange.ContainsKey($key)) { return $Global:RegexRange[$key] }


    if ($null -eq $Max -or $Min -eq $Max)
    {
        return $Min.ToString()
    }

    [int]$a = [Math]::Min($Min, $Max)
    [int]$b = [Math]::Max($Min, $Max)

    # S'il y a qu'une différence de 1, on peut retourner directement (Min|Max),
    # Min|Max ou (?:Min|Max) selon les options.
    if ([Math]::Abs($a - $b) -eq 1)
    {
        $result = "$Min|$Max"
        if ($Options.capture) { return "($result)" }
        if ($Options.wrap -eq $false) { return $result }
        return "(?:$result)"
    }

    $isPadded = (Test-HasPadding -String $Min) -or (Test-HasPadding -String $Max)
    $state = @{
        Min = $Min
        Max = $Max
        A   = $a
        B   = $b
    }
    $positives = @()
    $negatives = @()

    if ($isPadded)
    {
        $state.isPadded = $isPadded;
        $state.MaxLen = $Max.ToString().Length
    }

    if ($a -lt 0)
    {
        $newMin = if ($b -lt 0) { [Math]::Abs($b) } else { 1 }
        $negatives = Split-ToPatterns -Min $newMin -Max ([Math]::Abs($a)) -Tok $state -Options $Options
        $a = $state.A = 0
    }

    if ($b -ge 0)
    {
        $positives = Split-ToPatterns -Min $a -Max $b -Tok $state -Options $Options
    }

    $state.Negatives = $negatives;
    $state.Positives = $positives;
    $state.result = Join-Patterns -Negatives $negatives -Positives $positives

    if ($Options.Capture)
    {
        $state.result = "($($state.result))"
    }
    elseif ($Options.Wrap -and ($positives.Count + $negatives.Count) -gt 1)
    {
        $state.result = "(?:$($state.result))"
    }

    #Set-RegexRangeState -CacheKey $key -State $state -ErrorAction SilentlyContinue
    return $state.result
}

















function Measure-Nines
{
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [Parameter(Mandatory)]
        [alias ('Nines', 'NumberOfNines', 'NB')]
        [int]$Len
    )

    $minString = $Min.ToString()

    try
    {
        # Extraire la partie de la chaîne sans les $Len derniers caractères (156 -> 1 si y'a 2 Len)
        $prefix = $minString.Substring(0, $minString.Length - $Len)
        # Ajouter les '9' répétés (1 -> 199 si y'a 2 Len)
        $resultString = $prefix + ('9' * $Len)
    }
    catch
    {
        $resultString = -1
    }

    return [int]$resultString
}







.\Write-RangeColorized.ps1
.\Private\Set-RegexRangeState.ps1


$Min = 16
$Max = 115
Write-RangeColorize -Min $min -Max $max


0..15 | ForEach-Object {
    $max = Get-Random -Maximum 100000 -Minimum 1
    $min = Get-Random -Maximum $max -Minimum 0
    Write-RangeColorize -Min $min -Max $max
    Pause
}

#44-579 !!!589 +10
# 37-839 !!!-849 +10

# 0-9
#59-387
# 121-580
# 53-926 ||| 931 +5
#60-272 !!! 277 +5
# 160-428