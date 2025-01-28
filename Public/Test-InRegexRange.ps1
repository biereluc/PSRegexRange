function Test-InRegexRange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int]$Number,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Result')]
        [string]$RegexRange,
        [switch]$ExactMatch

    )

    $match = [regex]::Match($Number.ToString(), $RegexRange)
    if ($ExactMatch.IsPresent) {
        $reverseMatch = [regex]::Match($Number.ToString(), $RegexRange, [System.Text.RegularExpressions.RegexOptions]::RightToLeft)
        return ($match.Value -eq $Number.ToString()) -or ($reverseMatch.Value -eq $Number.ToString())
    }
    return $match.Value -eq $Number.ToString()
}