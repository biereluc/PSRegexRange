<#
    .SYNOPSIS
    Sets or updates a regex range state in the global registry.

    .DESCRIPTION
    Manages regex range states by storing them in a global hashtable registry.
    Creates the global registry if it doesn't exist, or updates existing entries.

    .PARAMETER StateKey
    The unique identifier for the regex range state entry.

    .PARAMETER RangeState
    The state object containing regex range configuration data.

    .INPUTS
    System.String, System.Management.Automation.PSCustomObject

    .OUTPUTS
    None

    .EXAMPLE
    Set-RegexRangeState -Key "Pattern1" -RangeState $stateObject

    .NOTES
    Uses global variable $RegexRange as a registry for all states.
#>
function  Set-RegexRangeState
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [hashtable]$Cache,
        [Parameter(Mandatory)]
        [string]$Key,
        [Parameter(Mandatory)]
        [pscustomobject]$State
    )

    if ( -not $Cache)
    {
        $Cache = @{ $Key = $State }
    }
    elseif (-not $Cache.ContainsKey($Key))
    {
        $Cache[$Key] = $State
    }
    return $Cache
}