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
function Split-ToRanges
{
    [CmdletBinding()]
    #[OutputType([int[]])]
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [Parameter(Mandatory)]
        [int]$Max
    )

    $nines = 1
    $zeros = 1
    [int]$stop = Measure-Nines -Number $Min -NumberOfNen $nines
    $stops = @($Max)

    while ($Min -le $stop -and $stop -le $Max)
    {

        # Add the stop to the array if it doesn't already exist, like a new Set([max]) in JS.
        if ($stops -notcontains $stop) { $stops += $stop }
        $nines += 1
        $stop = Measure-Nines -Number $min -Nines $nines
    }

    $stop = (Measure-Zeros -Number ($Max + 1) -Zeros $zeros) - 1
    while ($Min -lt $stop -and $stop -le $max)
    {
        # Add the stop to the array if it doesn't already exist, like a new Set([max]) in JS.
        if ($stops -notcontains $stop) { $stops += $stop }
        $zeros += 1
        $stop = (Measure-Zeros -Number ($max + 1) -Zeros $zeros) - 1
    }

    [Array]::Sort($stops)
    return $stops
}
