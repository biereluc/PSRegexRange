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
function Select-Patterns
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false)]
        [array]$Reference = @(),
        [Parameter(Mandatory = $false)]
        [array]$Comparison = @(),
        [Parameter(Mandatory = $false)]
        [string]$Prefix,
        [Parameter(Mandatory)] # Préfixe à ajouter
        [bool]$Intersection # Intersection ou non
    )

    $result = @()

    foreach ($element in $Reference)
    {
        $string = $element.String

        # Ajouter uniquement si les deux sont négatifs...
        if (-not $Intersection -and -not (Test-ObjectContainsProperty -InputObject $Comparison -KeyName 'string' -Value $string))
        {
            $result += "$prefix$string"
        }

        # Ou si les deux sont positifs
        if ($Intersection -and (Test-ObjectContainsProperty -InputObject $Comparison -KeyName 'string' -Value $string))
        {
            $result += "$prefix$string"
        }
    }

    return $result
}