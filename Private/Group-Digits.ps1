function Group-Digits
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Start,
        [Parameter(Mandatory)]
        [string]$Stop
    )

    $arr = @()
    for ($i = 0; $i -lt $Start.Length; $i++)
    {
        $arr += , @($Start[$i], $Stop[$i])
    }
    return , $arr # Force le retour comme un tableau structuré
}