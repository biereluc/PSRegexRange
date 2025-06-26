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
function ConvertTo-RangeToPattern
{
    [OutputType([System.Collections.Hashtable])]
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
            Pattern = $Start
            Counter = [System.Collections.ArrayList]@()
            Digits  = 0
        }
    }

    $zipped = Group-Digit -Start $Start -Stop $Stop
    $digits = $zipped.Count # longeur
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
        Pattern = $pattern
        Counter = [System.Collections.ArrayList]@($count)
        Digits  = $digits
    }
}