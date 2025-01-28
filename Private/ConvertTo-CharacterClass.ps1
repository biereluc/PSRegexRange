function ConvertTo-CharacterClass
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias ('StartDigit')]
        [int]$A,
        [Parameter(Mandatory)]
        [Alias ('StopDigit')]
        [int]$B
    )

    if ($b - $a -eq 1)
    {
        return "[$a$b]"
    }
    else
    {
        return "[$a-$b]"
    }
}