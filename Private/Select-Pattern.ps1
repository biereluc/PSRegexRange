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
function Select-Pattern
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
        [Parameter(Mandatory)]
        [bool]$Intersection
    )

    $result = @()

    foreach ($element in $Reference)
    {
        $string = $element.String

        # Add only if both are negative...
        if (-not $Intersection -and -not (Test-ObjectContainsProperty -InputObject $Comparison -KeyName 'string' -Value $string))
        {
            $result += "$prefix$string"
        }

        # AAdd only if both are positive...
        if ($Intersection -and (Test-ObjectContainsProperty -InputObject $Comparison -KeyName 'string' -Value $string))
        {
            $result += "$prefix$string"
        }
    }

    return $result
}