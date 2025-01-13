
function Test-HasPadding
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$String
    )
    return $String -match '^-?(0+)\d'
}