function Group-Digits
{
    param (
        [Parameter(Mandatory)]
        [string]$Start,
        [Parameter(Mandatory)]
        [string]$Stop
    )

    $arr = @()
    # if ($Start.Length -and $Stop.Length -eq 1)
    # {
    #     return , @( $Start, $Stop)
    # }
    for ($i = 0; $i -lt $Start.Length; $i++)
    {
        $arr += , @($Start[$i], $Stop[$i])
    }
    return , $arr # Force le retour comme un tableau structuré
}