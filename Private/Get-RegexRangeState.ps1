function Get-RegexRangeState
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key
    )

    if ($Global:RegexRange -and $Global:RegexRange.ContainsKey($key))
    {
        return $Global:RegexRange[$key]
    }
    return $null
}