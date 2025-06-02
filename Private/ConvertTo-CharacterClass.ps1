<#
    .SYNOPSIS
    Converts a range of digits into a character class representation.

    .DESCRIPTION
    Transforms a start and end digit into a regular expression character class notation.

    .PARAMETER StartDigit
    The starting digit of the range. Mandatory.

    .PARAMETER EndDigit
    The ending digit of the range. Mandatory.

    .EXAMPLE
    ConvertTo-CharacterClass -StartDigit 1 -EndDigit 3
    Returns "[1-3]"

    .INPUTS
    System.Int32 representing the start and end digits of the range.

    .OUTPUTS
    System.String representing a character class range.
#>

function ConvertTo-CharacterClass
{
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [int]$StartDigit,
        [Parameter(Mandatory)]
        [Alias ('StopDigit')]
        [int]$EndDigit
    )

    switch ($EndDigit - $StartDigit)
    {
        1 { return "[$StartDigit$EndDigit]" }
        default { return "[$StartDigit-$EndDigit]" }
    }
}