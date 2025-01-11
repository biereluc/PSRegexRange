function Select-Patterns
{
    param (
        [Parameter(Mandatory = $false)]
        [Alias ('Reference')]
        [array]$Arr = @(),
        [Parameter(Mandatory = $false)]
        [array]$Comparison = @(),
        [Parameter(Mandatory = $false)]
        [string]$Prefix,
        [Parameter(Mandatory)] # Préfixe à ajouter
        [bool]$Intersection # Intersection ou non
    )

    $result = @()

    foreach ($element in $Arr)
    {
        $string = $element.String

        # Ajouter uniquement si les deux sont négatifs...
        if (-not $Intersection -and -not (Test-Contains -Comparison $Comparison -Key 'string' -Value $string))
        {
            $result += "$prefix$string"
        }

        # Ou si les deux sont positifs
        if ($Intersection -and (Test-Contains -Comparison $Comparison -Key 'string' -Value $string))
        {
            $result += "$prefix$string"
        }
    }

    return $result
}