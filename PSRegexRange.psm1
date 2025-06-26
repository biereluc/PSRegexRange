<#
.DISCLAIMER
	THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
	THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.

	Copyright (c) Microsoft Corporation. All rights reserved.
#>

Set-StrictMode -Version Latest

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private))
{
    Try
    {
        $import | Unblock-File -Verbose
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message ('Failed to import function {0}: {1}' -f $import, $_)
    }
}

Export-ModuleMember -Function $Public.Basename
New-Alias -Name ctrr -Value ConvertTo-RegexRange -Force -Description 'Alias for ConvertTo-RegexRange from PSRegexRange module'
Export-ModuleMember -Cmdlet * -Alias *