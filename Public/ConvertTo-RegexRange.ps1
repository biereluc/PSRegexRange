

#https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-9.0
function ConvertTo-RegexRange
{
    [CmdletBinding(DefaultParameterSetName = 'ForcedOptionsSet')]
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

        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Wrap,

        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Capture,

        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$RelaxZeros,

        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Shorthand,

        [Parameter(ParameterSetName = 'ForcedOptionsSet')]
        [Parameter(
            helpmessage = 'Bypass the default options by passing a hashtable with `
                          the desired options or use the correct switch to override the default options.'
        )]
        # Default options
        [hashtable]$Options = @{
            RelaxZeros = $true
            Shorthand  = $false
            Capture    = $false
            Wrap       = $true
        }
    )

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
        'ForcedOptionsSet'
        {
            @{
                RelaxZeros = $Options.RelaxZeros -eq $true
                Shorthand  = $Options.Shorthand -eq $true
                Capture    = $Options.Capture -eq $true
                Wrap       = $Options.Wrap -eq $true
            }
        }
    }


    $key = "$min`:$max=$($Options.RelaxZeros)$($Options.Shorthand)$($Options.Capture)$($Options.Wrap)"
    $cachedResult = Get-RegexRangeState -Key $key
    if ($cachedResult)
    {
        #return $cachedResult
    }

    $state = New-State -Min $Min -Max $Max

    if ([string]::IsNullOrWhiteSpace($Max) -or $Min -eq $Max)
    {
        $state = Edit-State -Min $Min -Result $Min
        Set-RegexRangeState -Key $key -State $state -ErrorAction SilentlyContinue
        return $state
    }

    [int]$a = [Math]::Min($Min, $Max)
    [int]$b = [Math]::Max($Min, $Max)

    if ([Math]::Abs($a - $b) -eq 1)
    {
        $result = "$Min|$Max"
        if ($Options.capture) { $result = "($result)" }
        if ($Options.wrap -eq $false) { $result = $result }
        $result =  "(?:$result)"
        return Edit-State -Min $Min -Max $Max -A $a -B $b -Result $result
    }

    $isPadded = (Test-HasPadding -String $Min) -or (Test-HasPadding -String $Max)

    $state = Edit-State -Min $Min -Max $Max -A $a -B $b
    $positives = @()
    $negatives = @()


    if ($isPadded)
    {
        $state = Edit-State -isPadded $isPadded -MaxLen $Max.ToString().Length
    }











    if ($a -lt 0)
    {
        $newMin = if ($b -lt 0) { [Math]::Abs($b) } else { 1 }
        $negatives = Split-ToPatterns -Min $newMin -Max ([Math]::Abs($a)) -Tok $state -Options $Options

        $a = 0
        $state = Edit-State -A 0
    }

    if ($b -ge 0)
    {
        $positives = Split-ToPatterns -Min $a -Max $b -Tok $state -Options $Options
    }


    $state = Edit-State -Negatives $negatives -Positives $positives -Result (Join-Patterns -Negatives $negatives -Positives $positives -GreaterFirst)

    if ($Options.Capture)
    {
        $state = Edit-State -Result "(?:$($state.Result))"
    }
    elseif ($Options.Wrap -and ($positives.Count + $negatives.Count) -gt 1)
    {
        $state = Edit-State -Result "(?:$($state.Result))"
    }

    Set-RegexRangeState -Key $key -State $state -ErrorAction SilentlyContinue
    return $state
}