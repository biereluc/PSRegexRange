<#
    .SYNOPSIS
    Calculates the upper bound value by replacing trailing digits with nines.

    .DESCRIPTION
    Generates the maximum possible integer value within the same digit class by replacing
    the last specified number of digits with 9s. This creates the upper boundary before
    transitioning to the next order of magnitude.

    .PARAMETER Number
    The base number from which to derive the upper bound value.

    .PARAMETER Len
    The number of trailing digits to replace with 9s.

    .EXAMPLE
    Measure-Nines -Number 156 -Len 2
    # Returns 199 (replaces last 2 digits: 1 + "99")

    .INPUTS
    System.Int32. The base number and length can be piped to this function.

    .OUTPUTS
    System.Int32. The maximum value with the specified number of 9s.

    .FUNCTIONALITY
    Range calculation, Upper bound generation, Digit manipulation
#>
function Measure-Nines
{
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [Alias('Min', 'Integer', 'BaseNumber')]
        [int]$Number,
        [Parameter(Mandatory)]
        [alias ('Nines', 'NumberOfNen', 'TrailingDigits')]
        [int]$Len
    )

    # More efficient way to calculate the upper bound value
    $powerOfTen = [Math]::Pow(10, $Len)
    return ([Math]::Floor($Number / $powerOfTen) * $powerOfTen) + ($powerOfTen - 1)
}

# Old implementation for reference, kept for historical context
# $numberString = $Number.ToString()
# try {
#     $prefix = $numberString.Substring(0, $numberString.Length - $Len)
# } catch {
#     $prefix = ''
# }
# $resultString = $prefix + ('9' * $Len)
# return [int]::Parse($resultString)