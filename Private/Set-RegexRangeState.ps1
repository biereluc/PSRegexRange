function  Set-RegexRangeState
{
    param (
        [Parameter(Mandatory)]
        [string]$CacheKey,
        [Parameter(Mandatory)]
        [hashtable]$State
    )
    [hashtable]$Global:RegexRange[$CacheKey] = $State
}