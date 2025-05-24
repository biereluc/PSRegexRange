function Edit-State
{
    [CmdletBinding()]
    param(
        [psobject]$InputState,
        [string]$Min,
        [string]$Max,
        [int]$A,
        [int]$B,
        [bool]$isPadded,
        [int]$MaxLen,
        [array]$Negatives,
        [array]$Positives,
        [string]$Result
    )

    foreach ($param in $PSBoundParameters.GetEnumerator())
    {
        $InputState | Add-Member -MemberType NoteProperty -Name $param.Key -Value $param.Value -Force
    }

    if ($PSBoundParameters.ContainsKey('Result'))
    {
        # Set a default display property for the object to automatically show the regex result
        # when it is not used within a pipeline function.
        $defaultDisplaySet = 'Result'
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $InputState | Add-Member MemberSet PSStandardMembers $PSStandardMembers -Force
    }

    return $InputState
}