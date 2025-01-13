function Split-ToPatterns
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [Parameter(Mandatory)]
        [int]$Max,
        [Parameter(Mandatory)]
        $Tok,
        [Parameter(Mandatory)]
        [hashtable]$Options
    )

    [array]$ranges = @()
    [array]$ranges = Split-ToRanges -Min $Min -Max $Max
    [array]$tokens = @()
    [int]$start = $Min
    [psobject]$prev = $null

    for ($i = 0; $i -lt $ranges.Count; $i++)
    {
        $max = $ranges[$i]
        $obj = Convert-RangeToPattern -Start $Start.ToString() -Stop $max.ToString() -Options $Options
        $zeros = ''

        if (-not $Tok.isPadded -and $prev -and $prev.pattern -eq $obj.pattern)
        {
            if ($prev.count.Count -gt 1)
            {
                $prev.count.RemoveAt($prev.count.Count - 1)
            }
            $prev.count.Add($obj.count[0])
            $prev.string = $prev.pattern + (ConvertTo-Quantifier -Digits $prev.count)
            $start = $rangeMax + 1
            continue
        }

        if ($Tok.isPadded)
        {
            $zeros = Add-ZeroPadding -Max $ranges[$i] -Tok $tok -Options $options
        }

        $obj.string = $zeros + $obj.pattern + (ConvertTo-Quantifier -Digits $obj.count)
        $tokens += $obj
        $start = [int]$ranges[$i] + 1
        $prev = $obj
    }

    return $tokens
}