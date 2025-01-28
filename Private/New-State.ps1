function New-State
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Min,
        [string]$Max
    )

    $script:State = [PSCustomObject]@{
        Min = $Min
        Max = $Max
    }
    return $script:State
}