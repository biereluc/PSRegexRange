function ConvertTo-CharacterClass
{
    param (
        [Parameter(Mandatory)]
        [Alias ('StartDigit')]
        [string]$A,
        [Parameter(Mandatory)]
        [Alias ('StopDigit')]
        [string]$B
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