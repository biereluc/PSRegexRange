function ConvertTo-RegexRange
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
                if ($_ -as [int]) { return $true }
                throw "« $_ » must be an integer"
            })]
        [string]$Min,
        [Parameter(Mandatory)]
        [ValidateScript({
                if ($_ -as [int]) { return $true }
                throw "« $_ » must be an integer"
            })]
        [string]$Max,
        [hashtable]$Options = @{
            RelaxZeros = $true
            Shorthand  = $false
            Capture    = $false
            Wrap       = $true
        },
        [switch]$Wrap,
        [switch]$Capture,
        [switch]$RelaxZeros,
        [switch]$Shorthand
    )

    if ((-not $Min -as [int]) -and (-not $Max -as [int]))
    {
        throw 'Min and Max must be integers'
    }

    $Options = @{
        RelaxZeros = $RelaxZeros.IsPresent
        Shorthand  = $Shorthand.IsPresent
        Capture    = $Capture.IsPresent
        Wrap       = $Wrap.IsPresent
    }

    $key = "$min`:$max=$($Options.RelaxZeros)$($Options.Shorthand)$($Options.Capture)$($Options.Wrap)"
    $cachedResult = Get-RegexRangeState -Key $key
    if ($cachedResult)
    {
        return $cachedResult.Result
    }

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
    $state = [PSCustomObject]@{
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

    $state | Add-Member -MemberType NoteProperty -Name 'Negatives' -Value $negatives
    $state | Add-Member -MemberType NoteProperty -Name 'Positives' -Value $positives
    $state | Add-Member -MemberType NoteProperty -Name 'Result' -Value (Join-Patterns -Negatives $negatives -Positives $positives)

    # $state.Negatives = $negatives;
    # $state.Positives = $positives;
    # $state.Result = Join-Patterns -Negatives $negatives -Positives $positives

    if ($Options.Capture)
    {
        $state.result = "($($state.result))"
    }
    elseif ($Options.Wrap -and ($positives.Count + $negatives.Count) -gt 1)
    {
        $state.result = "(?:$($state.result))"
    }

    Set-RegexRangeState -Key $key -State $state -ErrorAction SilentlyContinue
    return $state.result
}

# ! Temporary
Get-ChildItem -Path '..\Private\*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path .\Write-RegexRangeColorized.ps1 | ForEach-Object { . $_.FullName }

ConvertTo-RegexRange -Min 10 -Max 16 | Write-RegexRangeColorized -Wait
ConvertTo-RegexRange -Min 10 -Max 16 | Write-RegexRangeColorized -Wait


#! Test
0..15 | ForEach-Object {
    $max = Get-Random -Maximum 1000 -Minimum 1
    $min = Get-Random -Maximum $max -Minimum 0
    ConvertTo-RegexRange -Min $min -Max $max | Write-RegexRangeColorized -Min $min -Max $max -Wait -Boundary 2
}