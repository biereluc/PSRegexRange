

function ConvertTo-RegexRange
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Parameter(ParameterSetName = 'Explicit')]
        [Parameter(ParameterSetName = 'Options')]
        [ValidateScript({
                if ($_ -as [int]) { return $true }
                throw "« $_ » must be an integer"
            })]
        [string]$Min,

        [Parameter(ParameterSetName = 'Explicit')]
        [Parameter(ParameterSetName = 'Options')]
        [ValidateScript({
                if ($_ -as [int]) { return $true }
                throw "« $_ » must be an integer"
            })]
        [string]$Max,
        [Parameter(
            helpmessage = 'Bypass the default options by passing a hashtable with `
                          the desired options or use the correct switch to override the default options.'
        )]

        [Parameter(ParameterSetName = 'Explicit')]
        [switch]$Wrap,

        [Parameter(ParameterSetName = 'Explicit')]
        [switch]$Capture,

        [Parameter(ParameterSetName = 'Explicit')]
        [switch]$RelaxZeros,

        [Parameter(ParameterSetName = 'Explicit')]
        [switch]$Shorthand,

        [Parameter(ParameterSetName = 'Options')]
        [hashtable]$Options = @{
            RelaxZeros = $true
            Shorthand  = $false
            Capture    = $false
            Wrap       = $true
        }
    )


    $Options = switch ($PSCmdlet.ParameterSetName)
    {
        'Explicit'
        {
            @{
                RelaxZeros = $RelaxZeros.IsPresent
                Shorthand  = $Shorthand.IsPresent
                Capture    = $Capture.IsPresent
                Wrap       = $Wrap.IsPresent
            }
        }
        'Options'
        {
            @{
                RelaxZeros = $Options.RelaxZeros -eq $true
                Shorthand  = $Options.Shorthand -eq $true
                Capture    = $Options.Capture -eq $true
                Wrap       = $Options.Wrap -eq $true
            }
        }
    }


    $key = "$min`:$max=$($Options.RelaxZeros)$($Options.Shorthand)$($Options.Capture)$($Options.Wrap)"
    $cachedResult = Get-RegexRangeState -Key $key
    if ($cachedResult)
    {
        return $cachedResult.Result
    }

    if ($null -eq $Max -or $Min -eq $Max)
    {
        return $Min.ToString()
    }

    [int]$a = [Math]::Min($Min, $Max)
    [int]$b = [Math]::Max($Min, $Max)

    if ([Math]::Abs($a - $b) -eq 1)
    {
        $result = "$Min|$Max"
        if ($Options.capture) { return "($result)" }
        if ($Options.wrap -eq $false) { return $result }
        return "(?:$result)"
    }

    $isPadded = (Test-HasPadding -String $Min) -or (Test-HasPadding -String $Max)
    $state = [PSCustomObject]@{
        Min = $Min
        Max = $Max
        A   = $a
        B   = $b
    }
    $positives = @()
    $negatives = @()

    if ($isPadded)
    {
        $state.isPadded = $isPadded;
        $state.MaxLen = $Max.ToString().Length
    }

    if ($a -lt 0)
    {
        $newMin = if ($b -lt 0) { [Math]::Abs($b) } else { 1 }
        $negatives = Split-ToPatterns -Min $newMin -Max ([Math]::Abs($a)) -Tok $state -Options $Options
        $a = $state.A = 0
    }

    if ($b -ge 0)
    {
        $positives = Split-ToPatterns -Min $a -Max $b -Tok $state -Options $Options
    }

    $state | Add-Member -MemberType NoteProperty -Name 'Negatives' -Value $negatives
    $state | Add-Member -MemberType NoteProperty -Name 'Positives' -Value $positives
    $state | Add-Member -MemberType NoteProperty -Name 'Result' -Value (Join-Patterns -Negatives $negatives -Positives $positives -GreaterFirst)

    # Set a default display property for the object to automatically show the regex result
    # when it is not used within a pipeline function.
    $defaultDisplaySet = 'Result'
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $state | Add-Member MemberSet PSStandardMembers $PSStandardMembers

    if ($Options.Capture)
    {
        $state.result = "($($state.result))"
    }
    elseif ($Options.Wrap -and ($positives.Count + $negatives.Count) -gt 1)
    {
        $state.result = "(?:$($state.result))"
    }

    Set-RegexRangeState -Key $key -State $state -ErrorAction SilentlyContinue
    return $state
}















# ! Temporary
Get-ChildItem -Path '.\Private\*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path .\Public\Write-RegexRangeColorized.ps1 | ForEach-Object { . $_.FullName }

$Min = 1058
$Max = 16985


ConvertTo-RegexRange -Min $Min -Max $Max -Options @{ RelaxZeros = $true; Shorthand = $true; }
ConvertTo-RegexRange -Min $Min -Max $Max -RelaxZeros | Write-RegexRangeColorized -Wait
# ConvertTo-RegexRange -Min 10 -Max 16 | Write-RegexRangeColorized -Wait


#! Test
Pause
0..15 | ForEach-Object {
    $max = Get-Random -Maximum 1000 -Minimum 1
    $min = Get-Random -Maximum $max -Minimum 0
    ConvertTo-RegexRange -Min $Min -Max $Max -RelaxZeros | Write-RegexRangeColorized -Wait -Boundary 2
}