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
function Join-Pattern
{
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false)]
        [array]$Negatives = @(),
        [Parameter(Mandatory = $false)]
        [array]$Positives = @()
    )

    $onlyNegative = @(Select-Pattern -Reference $Negatives -Comparison $Positives -Prefix '-' -Intersection $false)
    $onlyPositive = @(Select-Pattern -Reference $Positives -Comparison $Negatives -Prefix '' -Intersection $false)
    $intersected = @(Select-Pattern -Reference $Negatives -Comparison $Positives -Prefix '-?' -Intersection $true)
    $subpatterns = $onlyNegative + $intersected + $onlyPositive

    return ($subpatterns -join '|')
}