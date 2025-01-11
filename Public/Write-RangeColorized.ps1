function Write-RegexRangeColorized
{
    [CmdletBinding()]
    param (
        
        [Parameter(Mandatory)]
        [int]$Min,

        [Parameter(Mandatory = $false)]
        [int]$Max,

        [Parameter(Mandatory = $false)]
        [int]$Boundary = 10
    )

    # Génère le pattern regex
    $regex = ConvertTo-RegexRange -Min $Min -Max $Max

    # Affiche les informations
    Write-Host "Regex: $regex" -ForegroundColor Yellow
    Write-Host "Min: $Min" -ForegroundColor Yellow
    Write-Host "Max: $Max" -ForegroundColor Yellow

    # Test les valeurs autour de la plage
    $rangeStart = $Min - $Boundary
    $rangeEnd = $Max + $Boundary

    $rangeStart..$rangeEnd | ForEach-Object {
        $currentValue = $_
        $match = [regex]::Match($currentValue, $regex)

        # Affiche selon le type de correspondance
        if ($match.Success -and $match.Value -eq $currentValue)
        {
            Write-Host $currentValue -ForegroundColor Green
        }
        elseif ($match.Success)
        {
            $parts = $currentValue -split $match.Value
            foreach ($part in $parts)
            {
                if ([string]::IsNullOrEmpty($part))
                {
                    Write-Host $match.Value -ForegroundColor Green -NoNewline
                }
                else
                {
                    Write-Host $part -ForegroundColor Red -NoNewline
                }
            }
            Write-Host
        }
        else
        {
            Write-Host $currentValue -ForegroundColor Red
        }
    }
}

write-RangeColorized -Min 1