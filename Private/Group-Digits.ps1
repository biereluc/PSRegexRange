function Group-Digits
{
    [CmdletBinding()]
    param (
        # doit être des strings zipper les char
        [Parameter(Mandatory)]
        [int]$Start,
        [Parameter(Mandatory)]
        [int]$Stop
    )
    [string]$strStart = $Start.ToString()
    [string]$strStop = $Stop.ToString()

    $arr = @()
    $minLength = [Math]::Min($strStart.Length, $strStop.Length)
    for ($i = 0; $i -lt $minLength; $i++)
    {
        # Reconvert char to int.
        $digit1 = [int]::Parse($strStart[$i].ToString())
        $digit2 = [int]::Parse($strStop[$i].ToString())
        $arr += , @($digit1, $digit2)
    }
    return , $arr # Force le retour comme un tableau structuré
}