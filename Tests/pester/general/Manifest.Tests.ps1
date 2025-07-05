BeforeDiscovery {
    $module = $Script:moduleRessources
    # Using Import-PowerShellDataFile over Test-ModuleManifest as it's easier to navigate
    $manifest = Import-PowerShellDataFile -Path $module.ManifestPath
}

Describe 'Validating the module manifest' -ForEach @{ module = $module; manifest = $manifest } {
    Context 'Basic resources validation' {
        BeforeAll {
            $files = Get-ChildItem -Path "$($module.Root)/public" -Recurse -File -Filter '*.ps1'
        }

        It 'Manifest is valid' -Skip:$(($PSVersionTable.PSVersion.Major -ge 7)) {

            Test-ModuleManifest -Path $module.ManifestPath
            # Throws error if not valid = failure. Success if not.

            # Throws error if RootModule is set in PowerShell 7 host
            # Be like : The module manifest 'ModuleName' could not be processed because it is not a valid PowerShell
            #           module manifest file. Remove the elements that are not permitted
        }

        It 'Exports all functions in the public folder' {
            $functions = (Compare-Object -ReferenceObject $files.BaseName -DifferenceObject $manifest.FunctionsToExport | Where-Object SideIndicator -Like '<=').InputObject
            $functions | Should -BeNullOrEmpty
        }
        It "Exports no function that isn't also present in the public folder" {
            $functions = (Compare-Object -ReferenceObject $files.BaseName -DifferenceObject $manifest.FunctionsToExport | Where-Object SideIndicator -Like '=>').InputObject
            $functions | Should -BeNullOrEmpty
        }

        It 'Exports none of its internal functions' {
            $files = Get-ChildItem "$($module.Root)/private" -Recurse -File -Filter '*.ps1'
            $files | Where-Object BaseName -In $manifest.FunctionsToExport | Should -BeNullOrEmpty
        }
    }

    Context 'Testing tags' {
        It "Tag '<_>' should not include whitespace" -ForEach @($manifest.PrivateData.PSData.Tags) {
            $_ | Should -Not -Match '\s'
        }
    }

    Context 'Individual file validation' {
        It 'The root module file exists' {
            Join-Path -Path $module.Root -ChildPath $manifest.RootModule | Should -Exist
        }

        Context 'Testing format files' -Skip:$(-not $manifest.ContainsKey('FormatsToProcess')) {
            It 'The file <_> should exist' -ForEach $manifest.FormatsToProcess {
                Join-Path -Path $module.Root -ChildPath $_ | Should -Exist
            }
        }

        Context 'Testing types files' -Skip:$(-not $manifest.ContainsKey('TypesToProcess')) {
            It 'The file <_> should exist' -ForEach $manifest.TypesToProcess {
                Join-Path -Path $module.Root -ChildPath $_ | Should -Exist
            }
        }
    }
}