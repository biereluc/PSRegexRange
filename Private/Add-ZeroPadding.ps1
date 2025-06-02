<#
    .SYNOPSIS
    Generates zero padding regex pattern based on a numeric value

    .DESCRIPTION
    Creates zero padding regex patterns for numeric values with optional relaxed quantifier.

    .PARAMETER Value
    The numeric value to be padded.

    .PARAMETER Tok
    A token state object containing configuration for padding, including MaxLen property.

    .PARAMETER Options
    Configuration options for padding, including RelaxZeros setting.

    .EXAMPLE
    Add-ZeroPadding -Value 5 -Tok @{MaxLen = 3} -Options @{RelaxZeros = $true}
    Returns '0?' as zero padding.

    .OUTPUTS
    System.String. A string representing zero padding.

    .NOTES
    Supports flexible zero padding with optional relaxed mode.
#>
function Add-ZeroPadding
{
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [int]$Value,
        [Parameter(Mandatory)]
        [PSObject]$Tok,
        [Parameter(Mandatory)]
        $Options
    )

    if ($null -eq $Tok.PSObject.Properties['isPadded'] -and (-not $Tok.isPadded))
    {
        return $Value.ToString()
    }

    $paddingDifference = [Math]::Abs($Tok.MaxLen - $Value.ToString().Length)
    $useRelaxedQuantifiers = $Options.RelaxZeros -ne $false

    switch ($paddingDifference)
    {
        0 { return '' }
        1 { return $(if ($useRelaxedQuantifiers) { '0?' } else { '0' }) }
        2 { return $(if ($useRelaxedQuantifiers) { '0{0,2}' } else { '00' }) }
        default
        {
            return $(if ($useRelaxedQuantifiers) { "0{0,$paddingDifference}" } else { "0{$paddingDifference}" })
        }
    }
}