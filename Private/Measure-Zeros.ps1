function Measure-Zeros
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [alias ('Max', 'Next')]
        [int]$Integer,
        [Parameter(Mandatory)]
        [int]$Zeros
    )
    $powerOfTen = [math]::Pow(10, $Zeros)
    return [int]$Integer - ($Integer % $powerOfTen)
}