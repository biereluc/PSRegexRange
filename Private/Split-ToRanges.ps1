function Split-ToRanges
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$Min,
        [Parameter(Mandatory)]
        [int]$Max
    )

    [int]$nines = 1
    [int]$zeros = 1
    [int]$stop = Measure-Nines -Min $Min -Nines $nines
    $stops = @($Max)

    while ($Min -le $stop -and $stop -le $Max)
    {

        # Add the stop to the array if it doesn't already exist, like a new Set([max]) in JS.
        if ($stops -notcontains $stop) { $stops += $stop }
        #! $stops += $stop
        $nines += 1
        $stopOrNull = Measure-Nines -Min $min -Nines $nines
        if ($null -eq $stopOrNull) { break }
        $stop = $stopOrNull
    }

    $stop = (Measure-Zeros -Integer ($Max + 1) -Zeros $zeros) - 1
    while ($Min -lt $stop -and $stop -le $max)
    {
        # Add the stop to the array if it doesn't already exist, like a new Set([max]) in JS.
        if ($stops -notcontains $stop) { $stops += $stop }
        #! $stops += $stop
        $zeros += 1
        $stopOrNull = (Measure-Zeros -Integer ($max + 1) -Zeros $zeros) - 1
        if ($null -eq $stopOrNull) { break }
        $stop = $stopOrNull
    }

    [Array]::Sort($stops)
    return $stops
}
