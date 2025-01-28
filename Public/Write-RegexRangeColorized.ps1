function Write-RegexRangeColorized
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int]$Min,
        [Parameter(ValueFromPipelineByPropertyName)]
        # [ValidateScript({
        #         if ($_ -eq "" -or $_ -as [int]) { return $true }
        #         throw "« $_ » must be an integer"
        #     })]
        [string]$Max = '',
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Result')]
        [string]$Regex,
        [Parameter()]
        [int]$Boundary = 10,
        [Parameter()]
        [switch]$Wait
    )

    if (-not $Max) { $Max = $Min }
    # Test les valeurs autour de la plage
    $rangeStart = $Min - $Boundary
    $rangeEnd = [int]$Max + $Boundary

    $rangeStart..$rangeEnd | ForEach-Object {
        $currentValue = $_.ToString()
        $match = [regex]::Match($currentValue, $regex)

        if ($currentValue -eq -10)
        {
            $null = $null
        }

        if (($match.Success -and $currentValue -eq $match.Value) -or (Test-InRegexRange -Number $currentValue -RegexRange $regex -ExactMatch))
        {
            Write-Host $currentValue -ForegroundColor Green -NoNewline
        }
        else
        {

            # On récupère la valeur du match et sa position dans la chaîne
            $matchValue = $match.Value
            $matchIndex = $match.Index
            $matchLength = $matchValue.Length

            # On affiche la partie avant le match en rouge
            if ($matchIndex -gt 0)
            {
                $beforeMatch = $currentValue.Substring(0, $matchIndex)
                Write-Host $beforeMatch -ForegroundColor Red -NoNewline
            }

            # On affiche le match en vert
            Write-Host $matchValue -ForegroundColor Green -NoNewline

            # On affiche la partie après le match en rouge
            $remainingString = $currentValue.Substring($matchIndex + $matchLength)
            if (-not [string]::IsNullOrEmpty($remainingString))
            {
                Write-Host $remainingString -ForegroundColor Red -NoNewline
            }
        }

        if (($Min -eq $currentValue) -or ($Max -eq $currentValue))
        {
                if ($Min -eq $currentValue)
                {
                    Write-Host ' : Minimun range' -ForegroundColor Yellow -NoNewline
                }
                else
                {
                    Write-Host ' : Maximun range' -ForegroundColor Yellow -NoNewline
                }

        }
        Write-Host
        if ($Wait.IsPresent) { Start-Sleep -Seconds 1 }

    }

    if ($Wait.IsPresent)
    {
        Start-Sleep -Seconds 1
    }

}