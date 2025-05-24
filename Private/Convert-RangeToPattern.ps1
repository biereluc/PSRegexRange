
function Convert-RangeToPattern
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$Start,
        [Parameter(Mandatory)]
        [int]$Stop,
        [Parameter(Mandatory)]
        [hashtable]$Options
    )

    if ($Start -eq $Stop)
    {
        return @{
            pattern = $Start
            counter   = [System.Collections.ArrayList]@()
            digits  = 0
        }
    }

    $zipped = Group-Digits -Start $Start -Stop $Stop
    [int]$digits = $zipped.Count # longeur
    $pattern = ''
    $count = 0

    for ($i = 0; $i -lt $digits; $i++)
    {
        $startDigit, $stopDigit = $zipped[$i]

        if ($startDigit -eq $stopDigit)
        {
            $pattern += $startDigit
        }
        elseif ($startDigit -ne 0 -or $stopDigit -ne 9)
        {
            $pattern += (ConvertTo-CharacterClass -StartDigit $startDigit -StopDigit $stopDigit) # Create a character class ex: [1-9] [0-8] [1-4] [23]
        }
        # Else is [0-9]
        else
        {
            $count++
        }
    }

    if ($count -gt 0)
    {
        $pattern += if ($Options.shorthand -eq $true) { '\d' } else { '[0-9]' }
    }

    return @{
        pattern = $pattern
        counter   = [System.Collections.ArrayList]@($count)
        digits  = $digits
    }
}
