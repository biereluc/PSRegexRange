<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER

    .INPUTS

    .OUTPUTS

    .EXAMPLE

    .LINK

    .NOTES

    .FUNCTIONALITY
    #>
function Get-RegexRangeState
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [hashtable]$Cache,
        [Parameter(Mandatory)]
        [string]$Key
    )

    if ($Cache -and
        $null -ne $Cache -and
        $Cache -is [hashtable] -and
        $Cache.ContainsKey($key))
    {
        Write-Verbose "Retrieving state for key: $key"
        return $Cache[$key]
    }
    return $null
}