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
function ConvertTo-Quantifier
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Alias ('Count')]
        [array]$Digits
    )

    $start = if ($Digits.Count -gt 0) { $Digits[0] } else { 0 }
    $stop = if ($Digits.Count -gt 1) { $Digits[1] } else { '' }

    if ($stop -or $start -gt 1)
    {
        if (-not [string]::IsNullOrEmpty($stop))
        {
            return "{${start},${stop}}"
        }
        else
        {
            return "{${start}}"
        }
    }
    return ''
}