
<#
.SYNOPSIS
    Tests whether a number matches a specified regular expression range.

.DESCRIPTION
    Determines if a given number falls within a specified regular expression pattern, with optional regex options.

.PARAMETER Number
    The integer number to test against the regex range.

.PARAMETER RegexRange
    The regular expression pattern used to define the range or matching criteria.

.PARAMETER RegexOptions
    Optional regex options to modify the matching behavior. Defaults to None.

.INPUTS
    System.Int32
    System.Text.RegularExpressions.Regex
    System.Text.RegularExpressions.RegexOptions

.OUTPUTS
    System.Boolean

.EXAMPLE
    Test-InRegexRange -Number 42 -RegexRange '^\d{2}$'
    Returns $true if the number matches the specified regex pattern.

.EXAMPLE
    Test-InRegexRange -Number 42 -RegexRange '^[1-9]\d$' -RegexOptions IgnoreCase
    Tests the number with case-insensitive regex matching.

.LINK
    https://github.com/biereluc/PSRegexRange/blob/main/docs/Test-InRegexRange

.LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-9.0

.NOTES
    Converts the number to a string before performing regex matching.
#>
function Test-InRegexRange
{
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [int]$Number,
        [Parameter(Mandatory)]
        [Alias('Result')]
        [regex]$RegexRange,
        [System.Text.RegularExpressions.RegexOptions]$RegexOptions = [System.Text.RegularExpressions.RegexOptions]::None
    )

    Write-Verbose "Testing if number '$Number' matches regex range '$RegexRange'."
    $match = [regex]::Match($Number.ToString(), $RegexRange, $RegexOptions)
    return $match.Value -eq $Number.ToString()
}