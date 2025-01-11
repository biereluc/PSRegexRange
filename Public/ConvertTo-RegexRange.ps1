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

function Join-Patterns
{
    param (
        [Parameter(Mandatory = $false)]
        [array]$Negatives = @(),
        [Parameter(Mandatory = $false)]
        [array]$Positives = @()
    )

    $onlyNegative = Select-Patterns -Reference $Negatives -Comparison $Positives -Prefix '-' -Intersection $false
    $onlyPositive = Select-Patterns -Reference $Positives -Comparison $Negatives -Prefix '' -Intersection $false
    $intersected = Select-Patterns -Reference $Negatives -Comparison $Positives -Prefix '-?' -Intersection $true
    $subpatterns = $onlyNegative + $intersected + $onlyPositive

    return ($subpatterns -join '|')
}

function Split-ToRanges
{
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [Parameter(Mandatory)]
        [int]$Max
    )

    [int]$nines = 1
    [int]$zeros = 1
    [int]$stop = 0

    [int]$stop = Measure-Nines -Min $Min -Nines $nines
    $stops = @($Max)

    while ($Min -le $stop -and $stop -le $max)
    {
        $stops += $stop
        $nines += 1
        $stop = Measure-Nines -Min $min -Nines $nines
    }

    $stop = (Measure-Zeros -Integer ($max + 1) -Zeros $zeros) - 1
    while ($min -lt $stop -and $stop -le $max)
    {
        $stops += $stop
        $zeros += 1
        $stop = (Measure-Zeros -Integer ($max + 1) -Zeros $zeros) - 1
    }

    #!!! Trier les stops
    $stops = $stops | Sort-Object -Unique

    #$stops = $stops | Sort-Object { Compare-Values $_ $stops[0] }
    return $stops
}

function Convert-RangeToPattern
{
    param (
        [Parameter(Mandatory)]
        [int]$Start,
        [Parameter(Mandatory)]
        [int]$Stop,
        $Options
    )

    if ($Start -eq $Stop)
    {
        return @{
            pattern = $Start
            count   = @()
            digits  = 0
        }
    }

    $zipped = Zip -Start $Start -Stop $Stop
    [int]$digits = $zipped.Count
    $pattern = ''
    $count = 0

    for ($i = 0; $i -lt $digits; $i++)
    {
        $startDigit, $stopDigit = $zipped[$i]

        if ($startDigit -eq $stopDigit)
        {
            $pattern += $startDigit
        }
        elseif ("$startDigit" -ne '0' -or "$stopDigit" -ne '9')
        {
            $pattern += (ConvertTo-CharacterClass -StartDigit $startDigit -StopDigit $stopDigit)
        }
        else
        {
            $count++
        }
    }

    if ($count -gt 0)
    {
        $pattern += if ($Options.shorthand -eq $true) { '\d' } else { '[0-9]' }
    }

    return @{
        pattern = $pattern
        count   = @($count)
        digits  = $digits
    }
}


function Split-ToPatterns
{
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [int]$Max,
        $Tok,
        $Options
    )

    [array]$ranges = @()
    [array]$ranges = Split-ToRanges -Min $Min -Max $Max
    [array]$tokens = @()
    [int]$start = $Min
    [psobject]$prev = $null

    for ($i = 0; $i -lt $ranges.Count; $i++)
    {
        $max = $ranges[$i]
        $obj = Convert-RangeToPattern -Start $Start.ToString() -Stop $max.ToString() -Options $Options
        $zeros = ''

        if (-not $Tok.isPadded -and $prev -and $prev.pattern -eq $obj.pattern)
        {
            if ($prev.count.Count -gt 1)
            {
                $prev.count.RemoveAt($prev.count.Count - 1)
            }
            $prev.count.Add($obj.count[0])
            $prev.string = $prev.pattern + (ConvertTo-Quantifier -Digits $prev.count)
            $start = $rangeMax + 1
            continue
        }

        if ($Tok.isPadded)
        {
            $zeros = Add-ZeroPadding -Max $ranges[$i] -Tok $tok -Options $options
        }

        $obj.string = $zeros + $obj.pattern + (ConvertTo-Quantifier -Digits $obj.count)
        $tokens += $obj
        $start = [int]$ranges[$i] + 1
        $prev = $obj
    }

    return $tokens
}


function Select-Patterns
{
    param (
        [Parameter(Mandatory = $false)]
        [Alias ('Reference')]
        [array]$Arr = @(),
        [Parameter(Mandatory = $false)]
        [array]$Comparison = @(),
        [Parameter(Mandatory = $false)]
        [string]$Prefix,
        [Parameter(Mandatory)] # Préfixe à ajouter
        [bool]$Intersection # Intersection ou non
    )

    $result = @()

    foreach ($element in $Arr)
    {
        $string = $element.String

        # Ajouter uniquement si les deux sont négatifs...
        if (-not $Intersection -and -not (Test-Contains -Comparison $Comparison -Key 'string' -Value $string))
        {
            $result += "$prefix$string"
        }

        # Ou si les deux sont positifs
        if ($Intersection -and (Test-Contains -Comparison $Comparison -Key 'string' -Value $string))
        {
            $result += "$prefix$string"
        }
    }

    return $result
}



function Zip
{
    param (
        [Parameter(Mandatory)]
        [string]$Start,
        [Parameter(Mandatory)]
        [string]$Stop
    )

    $arr = @()
    # if ($Start.Length -and $Stop.Length -eq 1)
    # {
    #     return , @( $Start, $Stop)
    # }
    for ($i = 0; $i -lt $Start.Length; $i++)
    {
        $arr += , @($Start[$i], $Stop[$i])
    }
    return , $arr # Force le retour comme un tableau structuré
}


function Compare-Values
{
    param (
        [Parameter(Mandatory)]
        [int]$A,
        [Parameter(Mandatory)]
        [int]$B
    )
    if ($A -gt $B)
    {
        return 1
    }
    elseif ($B -gt $A)
    {
        return -1
    }
    else
    {
        return 0
    }
}

function Test-Contains
{
    param (
        [Parameter(Mandatory = $false)]
        [alias ('Comparison')]
        [array]$Arr = @(),
        [Parameter(Mandatory)]
        [string]$Key,
        [Parameter(Mandatory)]
        [alias ('Value')]
        [string]$Val
    )

    return ($Arr | Where-Object { $_.$key -eq $val }).Count -gt 0
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