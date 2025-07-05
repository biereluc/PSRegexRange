
function ConvertTo-RegexRange
{

    <#
.SYNOPSIS
    Converts a numeric range into a regular expression pattern.

.DESCRIPTION
    Generates a regex pattern that matches numbers within a specified range,
    with options for handling zero-padding, shorthand notation, and capturing groups.

.PARAMETER Minimum
    The minimum value of the numeric range. As a string but must be an integer.

.PARAMETER Maximum
    The maximum value of the numeric range. As a string but must be an integer.

.PARAMETER Wrap
    Optional switch to wrap the regex pattern in a non-capturing group.

.PARAMETER Capture
    Optional switch to wrap the regex pattern in a capturing group.

.PARAMETER RelaxZeros
    Optional switch to make leading zeros optional in the pattern.

.PARAMETER Shorthand
    Optional switch to use shorthand regex notation for digits.

.PARAMETER Options
    A hashtable to override default options for regex range generation.

.PARAMETER NoCache
    Switch to bypass caching and recalculate the regex range every time.

.INPUTS
    None. ConvertTo-RegexRange does not accept pipeline input.

.OUTPUTS
    System.Collections.Hashtable. ConvertTo-RegexRang returns a hashtable containing
    the minimum and maximum values, the computed regex pattern, and other state information.

.EXAMPLE
    ConvertTo-RegexRange -Minimum 0 -Maximum 100
    Generates a regex pattern matching numbers from 0 to 100.

.FUNCTIONALITY
    Regex Range Conversion

.ROLE
    Developer

.COMPONENT
    Regular Expressions

.NOTES
    Supports both positive and negative number ranges with flexible configuration options.

.LINK
    https://github.com/biereluc/PSRegexRange/blob/main/docs/ConvertTo-RegexRange

.LINK
    https://github.com/micromatch/to-regex-range

.LINK
    https://github.com/voronind/range-regex

.LINK
    https://www.npmjs.com/package/to-regex-range

.LINK
    https://regextutorial.org/regex-for-numbers-and-ranges.php

.LINK
    https://www.regex-range.com/

.LINK
    https://3widgets.com/

#>
    [CmdletBinding(DefaultParameterSetName = 'DefaultSet')]
    [OutputType([System.Collections.Hashtable])]
    [Alias('ctrr')]
    param (
        [Parameter(Mandatory,
            Position = 0,
            helpmessage = 'The minimum value of the numeric range.')]
        [ValidateScript({
                if ($_ -match '^-?\d+$') { return $true }
                throw "« $_ » must be an integer"
            })]
        [Alias('Min')]
        [string]$Minimum,

        [Parameter(Position = 1)]
        [ValidateScript({
                if ($_ -match '^-?\d+$') { return $true }
                throw "« $_ » must be an integer"
            })]
        [Alias('Max')]
        [string]$Maximum,

        # Add (?: ) to wrap the regex pattern in a non-capturing group
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Wrap,

        # Add ( ) to wrap the regex pattern in a capturing group
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Capture,

        # Make leading zeros optional in the pattern
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$RelaxZeros,

        # Remplace [0-9] to \d or \d{1,x}
        [Parameter(ParameterSetName = 'ExplicitSet')]
        [switch]$Shorthand,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'DefaultSet',
            helpmessage = 'Bypass the default options by passing a hashtable with `
                        the desired options or use the correct switch to override the default options.'
        )]
        # Default options if not explicitly set
        [hashtable]$Options = @{
            RelaxZeros = $true
            Shorthand  = $false
            Capture    = $false
            Wrap       = $false
        },
        # Do not use cache result, recalculate the regex range every time
        [switch]$NoCache
    )

    begin
    {
        Set-StrictMode -Version Latest
        $VerbosePreference = 'Continue'

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


        $cacheKey = "$Minimum`:$Maximum=$($Options.RelaxZeros)$($Options.Shorthand)$($Options.Capture)$($Options.Wrap)"
        if (-not (Get-Variable -Name cachedResult -ErrorAction Ignore)) { $cachedResult = $null }

        if (-not $NoCache.IsPresent)
        {
            $cachedResult = Get-RegexRangeState -Cache $cachedResult -Key $cacheKey
            if ($cachedResult)
            {
                return $cachedResult
            }
        }
    }

    process
    {
        Write-Verbose "Processing range from $Minimum to $Maximum."
        $state = @{}

        # If Max is not specified or Min and Max have the same value, set it to Min
        if ([string]::IsNullOrWhiteSpace($Maximum) -or $Minimum -eq $Maximum)
        {
            $state = @{
                Min    = $Minimum
                Result = $Minimum
            }
            return # to the end block
        }

        [int]$a = [Math]::Min($Minimum, $Maximum)
        [int]$b = [Math]::Max($Minimum, $Maximum)

        # If Min and Max are consecutive integers, return the range
        if ([Math]::Abs($a - $b) -eq 1)
        {
            $result = "$Minimum|$Maximum"
            if ($Options.capture) { $result = "($result)" }
            elseif ($Options.wrap -eq $false) { $result = $result }
            else
            {
                $result = "(?:$result)"
            }
            $state = @{
                Min    = $Minimum
                Max    = $Maximum
                A      = $a
                B      = $b
                Result = $result
            }
            return # to the end block
            #return $state
        }

        $isPadded = (Test-LeadingZero -Number $Minimum) -or (Test-LeadingZero -Number $Maximum)

        $state = $state = @{
            Min = $Minimum
            Max = $Maximum
            A   = $a
            B   = $b
        }
        $positives = @()
        $negatives = @()

        if ($isPadded)
        {
            $state.isPadded = $isPadded
            $state.MaxLen = $Maximum.ToString().Length
        } else {
            $state.isPadded = $false
        }

        if ($a -lt 0)
        {
            $newMin = if ($b -lt 0) { [Math]::Abs($b) } else { 1 }
            $negatives = Split-ToPattern -Min $newMin -Max ([Math]::Abs($a)) -Tok $state -Options $Options
            $state.A = 0
            $a = 0
        }

        if ($b -ge 0)
        {
            $positives = Split-ToPattern -Min $a -Max $b -Tok $state -Options $Options
        }

        $state.negatives = $negatives
        $state.positives = $positives
        $state.Result = (Join-Pattern -Negatives $negatives -Positives $positives)

        if ($Options.Capture)
        {
            $state.Result = "($($state.Result))"
        }
        elseif ($Options.Wrap -and ($positives.Count + $negatives.Count) -gt 1)
        {
            $state.Result = "(?:$($state.Result))"
        }
    }

    end
    {
        $cachedResult = Set-RegexRangeState -Cache $cachedResult -Key $cacheKey -State $state -ErrorAction SilentlyContinue
        return $state
    }
}