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
    [string]$Start = $Start.ToString()
    [string]$Stop = $Stop.ToString()

    $arr = @()
    for ($i = 0; $i -lt $Start.Length; $i++)
    {
        # Reconvert char to int.
        $arr += , @([int]::Parse($Start[$i]), [int]::Parse($Stop[$i]))
    }
    return , $arr # Force le retour comme un tableau structuré
}