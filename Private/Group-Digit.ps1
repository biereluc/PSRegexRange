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
function Group-Digit
{
    param (
        [Parameter(Mandatory)]
        [int]$Start,
        [Parameter(Mandatory)]
        [int]$Stop
    )
    $strStart = $Start.ToString()
    $strStop = $Stop.ToString()

    $arr = @()
    $minLength = [Math]::Min($strStart.Length, $strStop.Length)
    for ($i = 0; $i -lt $minLength; $i++)
    {
        # Reconvert char to int.
        $digit1 = [int]::Parse($strStart[$i].ToString())
        $digit2 = [int]::Parse($strStop[$i].ToString())
        $arr += , @($digit1, $digit2)
    }
    return , $arr # Force array return
    }