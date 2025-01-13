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
        if ([string]::IsNullOrEmpty($stop))
        {
            return "{${start}}"
        }
        else
        {
            return "{${start},${stop}}"
        }
    }
    return ''
}