function Measure-Nines
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [Parameter(Mandatory)]
        [alias ('Nines', 'NumberOfNen', 'NB')]
        [int]$Len
    )

    $minString = $Min.ToString()

    try
    {
        # Extraire la partie de la chaîne sans les $Len derniers caractères (156 -> 1 si y'a 2 Len)
        $prefix = $minString.Substring(0, $minString.Length - $Len)
    }
    catch
    {
        $prefix = ''
    }
    # Ajouter les '9' répétés (1 -> 199 si y'a 2 Len)
    $resultString = $prefix + ('9' * $Len)
    return [int]::Parse($resultString)



}