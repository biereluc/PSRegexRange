function  Set-RegexRangeState
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Key,
        [Parameter(Mandatory)]
        [pscustomobject]$State
    )
    if (-not $Global:RegexRange)
    {
        $Global:RegexRange = @{}
        $Global:RegexRange.Add($Key, $State)
    }
    elseif (-not $Global:RegexRange.ContainsKey($Key))
    {
        $Global:RegexRange[$Key] = $State
    }
}