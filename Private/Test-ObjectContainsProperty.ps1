<#
    .SYNOPSIS
    Tests whether a collection of objects contains an object with a specific key-value pair.

    .DESCRIPTION
    Searches through an input collection of objects to determine if any object has a property matching the specified key with the given value.

    .PARAMETER InputObject
    The collection of objects to search through. Defaults to an empty array if not provided.

    .PARAMETER Key
    The name of the property to search for in each object.

    .PARAMETER Value
    The value to match against the specified property.

    .OUTPUTS
    System.Boolean

    .EXAMPLE
    Test-ObjectContains -InputObject @($obj1, $obj2) -Key 'String' -Value '[0-9]{1}'
    Returns $true if any object in the collection has a 'String' property with the value '[0-9]{1}'.
#>
function Test-ObjectContainsProperty
{
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $false)]
        [alias ('Comparison', 'ObjectCollection', 'Collection')]
        [array]$InputObject = @(),
        [Parameter(Mandatory)]
        [alias ('KeyName', 'PropertyName')]
        [string]$Key,
        [Parameter(Mandatory)]
        [Alias('PropertyValue')]
        [string]$Value
    )

    # Early return if collection is empty
    if ($InputObject.Count -eq 0) {
        return $false
    }

    # Search through each object in the collection, returning true at the first match
    foreach ($element in $InputObject)
    {
        if ($element.$Key -eq $Value)
        {
            return $true
        }
    }
    return $false
}