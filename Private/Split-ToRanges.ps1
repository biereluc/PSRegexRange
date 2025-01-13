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
    [int]$stop = 0

    [int]$stop = Measure-Nines -Min $Min -Nines $nines
    $stops = @($Max)

    while ($Min -le $stop -and $stop -le $max)
    {
        $stops += $stop
        $nines += 1
        $stop = Measure-Nines -Min $min -Nines $nines
    }

    $stop = (Measure-Zeros -Integer ($max + 1) -Zeros $zeros) - 1
    while ($min -lt $stop -and $stop -le $max)
    {
        $stops += $stop
        $zeros += 1
        $stop = (Measure-Zeros -Integer ($max + 1) -Zeros $zeros) - 1
    }

    $stops = $stops | Sort-Object -Unique
    return $stops
}
