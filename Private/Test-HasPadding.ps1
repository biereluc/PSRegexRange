
# function hasPadding(str)
function Test-HasPadding
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$String
    )
    return [bool]($String -match '^-?(0+)\d')
}