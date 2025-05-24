#function padZeros(value, tok, options)
function Add-ZeroPadding
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [int]$Value,
        [Parameter(Mandatory)]
        [PSObject]$Tok,
        [Parameter(Mandatory)]
        $Options
    )

    if (-not $Tok.isPadded)
    {
        return $Value
    }

    $diff = [Math]::Abs($Tok.MaxLen - $Value.ToString().Length)
    $relax = $Options.RelaxZeros -ne $false

    switch ($diff)
    {
        0
        {
            return ''
        }
        1
        {
            return $(if ($relax) { '0?' } else { '0' })
        }
        2
        {
            return $(if ($relax) { '0{0,2}' } else { '00' })
        }
        default
        {
            return $(if ($relax) { "0{0,$diff}" } else { "0{$diff}" })
        }
    }
}