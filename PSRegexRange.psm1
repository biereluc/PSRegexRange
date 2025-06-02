Get-ChildItem -Path $PSScriptRoot -Recurse | Unblock-File
#-Requires -Modules blabla
#$PSModuleAutoloadingPreference = 'none'
#Set-StrictMode -Version Latest
#Microsoft.PowerShell.Utility\Import-LocalizedData  LocalizedData -filename PackageManagement.Resources.psd1

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename

# Set up some helper variables to make it easier to work with the module
#$script:PSModule = $ExecutionContext.SessionState.Module
##$script:PSModuleRoot = $script:PSModule.ModuleBase

#New-Alias Install-WindowsUpdate Get-WindowsUpdate
#New-Alias Download-WindowsUpdate Get-WindowsUpdate

#$PSDefaultParameterValues.Add("Install-WindowsUpdate:Install",$true)
#$PSDefaultParameterValues.Add("Download-WindowsUpdate:Download",$true)

#Import-Module -Name $modulePath

#Export-ModuleMember -Cmdlet * -Alias *