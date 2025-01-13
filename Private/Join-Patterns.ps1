function Join-Patterns
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [array]$Negatives = @(),
        [Parameter(Mandatory = $false)]
        [array]$Positives = @()
    )

    $onlyNegative = Select-Patterns -Reference $Negatives -Comparison $Positives -Prefix '-' -Intersection $false
    $onlyPositive = Select-Patterns -Reference $Positives -Comparison $Negatives -Prefix '' -Intersection $false
    $intersected = Select-Patterns -Reference $Negatives -Comparison $Positives -Prefix '-?' -Intersection $true
    $subpatterns = $onlyNegative + $intersected + $onlyPositive

    return [string]($subpatterns -join '|')
}