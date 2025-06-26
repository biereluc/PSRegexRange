function Split-ToPattern
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

    [array]$ranges = Split-ToRange -Min $Min -Max $Max
    [array]$tokens = @()
    [int]$start = $Min
    [psobject]$prev = $null

    for ($i = 0; $i -lt $ranges.Count; $i++)
    {

        $max = $ranges[$i]
        $obj = Convert-RangeToPattern -Start $Start.ToString() -Stop $max.ToString() -Options $Options
        $zeros = ''

        if ((-not $Tok.isPadded) -and $prev -and ($prev.pattern -eq $obj.pattern))
        {
            if ($null -eq $prev.counter)
            {
                $prev.counter = [System.Collections.ArrayList]@()
            }

            if ($prev.counter.Count -gt 1)
            {
                $prev.counter.RemoveAt($prev.counter.Count - 1)
            }
            [void]$prev.counter.Add($obj.counter[0])
            $prev.string = $prev.pattern + (ConvertTo-Quantifier -Digits $prev.counter) # Convert replicated pattern to quantifier. Ex: [0-9]{2}
            $start = [int]$max + 1
            continue
        }

        if ($Tok.isPadded)
        {
            $zeros = Add-ZeroPadding -Value $ranges[$i] -Tok $Tok -Options $options
        }

        $obj.string = $zeros + $obj.pattern + (ConvertTo-Quantifier -Digits $obj.counter) #
        $tokens += $obj
        $start = [int]$max + 1
        $prev = $obj
    }

    return $tokens
}