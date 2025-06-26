<#
    .SYNOPSIS
    Rounds down a number to the nearest multiple of a specified power of ten.

    .DESCRIPTION
    The Measure-Zero function takes a number and rounds it down to the nearest multiple of 10 raised to the specified number of zeros.

    .PARAMETER Number
    The input number to be rounded down.

    .PARAMETER Zeros
    The number of zeros to use when rounding down the input number.

    .INPUTS
    System.Int32, System.Int32

    .OUTPUTS
    System.Int32

    .EXAMPLE
    Measure-Zero -Number 1234 -Zeros 2
    # Returns 1200

    .NOTES
    This function provides a simple way to truncate a number to a specific decimal place.
#>
function Measure-Zero
{
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [alias ('Max', 'Next', 'Integer')]
        [int]$Number,
        [Parameter(Mandatory)]
        [int]$Zeros
    )
    $powerOfTen = [math]::Pow(10, $Zeros)
    return $Number - ($Number % $powerOfTen)
}