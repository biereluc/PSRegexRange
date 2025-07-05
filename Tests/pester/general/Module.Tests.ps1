BeforeDiscovery {
    $module = $Script:moduleRessources
    # Using Import-PowerShellDataFile over Test-ModuleManifest as it's easier to navigate
    $manifest = Import-PowerShellDataFile -Path $module.ManifestPath
}

Describe "$($module.Name) Module Tests" -Tags ('Unit', 'Acceptance') -ForEach @{ module = $module } {
    Context 'Module Setup' {
        It "has the root module $($module.ModuleFilename)" {
            $module.ModulePath | Should -Exist
        }

        It "has the a manifest file of $($module.ManifestFilename)" {
            $module.ManifestPath | Should -Exist
            $module.ManifestPath | Should -FileContentMatch $($module.ModuleFilename)
        }

        It "$($module.Name) folder has functions" {
            Join-Path -Path $module.Root -ChildPath 'public/*.ps1' | Should -Exist
        }

        It "$($module.Name) is valid PowerShell code" {
            $psFile = Get-Content -Path $module.ModulePath -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }

    } # Context 'Module Setup'
}