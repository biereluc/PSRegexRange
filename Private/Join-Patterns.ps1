function Join-Patterns
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [array]$Negatives = @(),
        [Parameter(Mandatory = $false)]
        [array]$Positives = @(),
        [Parameter(Mandatory = $false)]
        [alias('GreaterFirst', 'Descending')]
        [switch]$Reverse
    )

    $onlyNegative = Select-Patterns -Reference $Negatives -Comparison $Positives -Prefix '-' -Intersection $false
    $onlyPositive = Select-Patterns -Reference $Positives -Comparison $Negatives -Prefix '' -Intersection $false
    $intersected = Select-Patterns -Reference $Negatives -Comparison $Positives -Prefix '-?' -Intersection $true
    $subpatterns = $onlyNegative + $intersected + $onlyPositive

    # Reverse the order of the patterns to prioritize detecting the longest number in the range.
    # This fixes the issue in the original function where shorter numbers are detected first,
    # causing them to interfere with the detection of longer numbers within the same range.
    # It's similar to using the 'RightToLeft' option in a regex match search.
    if ($Reverse.IsPresent) { [array]::Reverse($subpatterns) }

    return [string]($subpatterns -join '|')
}