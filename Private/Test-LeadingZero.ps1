
<#
.SYNOPSIS
Checks if a string representing a number has leading zeros.

.DESCRIPTION
The Test-LeadingZero function determines whether a given numeric string contains leading zeros, including support for negative numbers.

.PARAMETER Number
The string representation of a number to check for leading zeros.

.INPUTS
System.String

.OUTPUTS
System.Boolean

.EXAMPLE
Test-LeadingZero "0042" # Returns $true
Test-LeadingZero "-0123" # Returns $true
Test-LeadingZero "42" # Returns $false

.NOTES
This function uses a regular expression to detect leading zeros in numeric strings.
#>
function Test-LeadingZero
{
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [Alias('String', 'NumericString')]
        [string]$Number
    )

    return $Number -match '^-?(0+)\d'
}