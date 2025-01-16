function Write-RegexRangeColorized
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$Min,
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$Max,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Result')]
        [string]$Regex,
        [Parameter()]
        [int]$Boundary = 10,
        [Parameter()]
        [switch]$Wait
    )
    if (-not $Regex)
    {
        $regex = ConvertTo-RegexRange -Min $Min -Max $Max
    }


    # Test les valeurs autour de la plage
    $rangeStart = $Min - $Boundary
    $rangeEnd = $Max + $Boundary

    $rangeStart..$rangeEnd | ForEach-Object {
        $currentValue = $_
        $match = [regex]::Match($currentValue, $regex)

        if (($Min -eq $currentValue) -or ($Max -eq $currentValue))
        {
            Write-Host $currentValue -ForegroundColor Yellow -NoNewline

            if ($Wait.IsPresent)
            {
                Start-Sleep -Seconds 1
                if ($Min -eq $currentValue)
                {
                    Write-Host ' : Minimun range' -ForegroundColor Yellow -NoNewline
                }
                else
                {
                    Write-Host ' : Maximun range' -ForegroundColor Yellow -NoNewline
                }
                Start-Sleep -Seconds 2
            }
            Write-Host
        }
        elseif ($match.Success -and $match.Value -eq $currentValue)
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
    Write-Host "Regex: $regex" -ForegroundColor Yellow
}