
function ConvertTo-RegexRange
{
    [CmdletBinding(DefaultParameterSetName = 'DefaultSet')]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
                if ($_ -match '^-?\d+$') { return $true }
                throw "« $_ » must be an integer"
            })]
        [string]$Min,

        [ValidateScript({
                if ($_ -match '^-?\d+$') { return $true }
                throw "« $_ » must be an integer"
            })]
        [string]$Max,

        # Ajoute (?: ) pour capturer la plage
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Wrap,

        # Ajouter des () pour capturer la plage
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Capture,

        # rend optionnel les zéros devant
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$RelaxZeros,

        # Remplace [0-9] par \d ou \d{1,x}
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Shorthand,

        [Parameter(ParameterSetName = 'DefaultSet')]
        [Parameter(
            helpmessage = 'Bypass the default options by passing a hashtable with `
                          the desired options or use the correct switch to override the default options.'
        )]
        # Default options
        [hashtable]$Options = @{
            RelaxZeros = $true
            Shorthand  = $false
            Capture    = $false
            Wrap       = $false
        },
        [switch]$NoCache
    )
    
    Set-StrictMode -Version Latest



    # Bypass the default options by passing a hashtable with the desired options
    # or use the correct switch to override the default options.
    $Options = switch ($PSCmdlet.ParameterSetName)
    {
        'ExplicitSet'
        {
            @{
                RelaxZeros = $RelaxZeros.IsPresent
                Shorthand  = $Shorthand.IsPresent
                Capture    = $Capture.IsPresent
                Wrap       = $Wrap.IsPresent
            }
        }
        'DefaultSet'
        {
            @{
                RelaxZeros = $Options.RelaxZeros -eq $true
                Shorthand  = $Options.Shorthand -eq $true
                Capture    = $Options.Capture -eq $true
                Wrap       = $Options.Wrap -eq $true
            }
        }
    }

    $cacheKey = "$min`:$max=$($Options.RelaxZeros)$($Options.Shorthand)$($Options.Capture)$($Options.Wrap)"
    if (-not $NoCache.IsPresent)
    {
        $cachedResult = Get-RegexRangeState -Key $cacheKey
        if ($cachedResult)
        {
            return $cachedResult
        }
    }

    $state = @{}

    # If Max is not specified or Min and Max have the same value, set it to Min
    if ([string]::IsNullOrWhiteSpace($Max) -or $Min -eq $Max)
    {
        $state = @{
            Min = $Min
            Result = $Min
        }
        return $state
    }

    [int]$a = [Math]::Min($Min, $Max)
    [int]$b = [Math]::Max($Min, $Max)

    # If Min and Max are consecutive integers, return the range
    if ([Math]::Abs($a - $b) -eq 1)
    {
        $result = "$Min|$Max"
        if ($Options.capture) { $result = "($result)" }
        elseif ($Options.wrap -eq $false) { $result = $result }
        else
        {
            $result = "(?:$result)"
        }
        $state = @{
            Min = $Min
            Max = $Max
            A = $a
            B = $b
            Result = $result
        }
        return $state
    }

    $isPadded = (Test-LeadingZeros -Number $Min) -or (Test-LeadingZeros -Number $Max)

    $state = $state = @{
            Min = $Min
            Max = $Max
            A = $a
            B = $b
    }
    $positives = @()
    $negatives = @()

    if ($isPadded)
    {
        $state.isPadded = $isPadded
        $state.MaxLen = $Max.ToString().Length
    }

    if ($a -lt 0)
    {
        $newMin = if ($b -lt 0) { [Math]::Abs($b) } else { 1 }
        $negatives = Split-ToPatterns -Min $newMin -Max ([Math]::Abs($a)) -Tok $state -Options $Options
        $state.A = 0
        $a = 0
    }

    if ($b -ge 0)
    {
        $positives = Split-ToPatterns -Min $a -Max $b -Tok $state -Options $Options
    }

    $state.negatives = $negatives
    $state.positives = $positives
    $state.Result = (Join-Patterns -Negatives $negatives -Positives $positives -GreaterFirst)

    if ($Options.Capture)
    {
        $state.Result = "($($state.Result))"
    }
    elseif ($Options.Wrap -and ($positives.Count + $negatives.Count) -gt 1)
    {
        $state.Result = "(?:$($state.Result))"
    }

    Set-RegexRangeState -Key $cacheKey -State $state -ErrorAction SilentlyContinue
    return $state
}