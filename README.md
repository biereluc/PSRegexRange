# PSRegexRange
[![PSGallery Version](https://img.shields.io/powershellgallery/v/PSRegexRange.svg?style=flat&logo=powershell&label=PSGallery%20Version)](https://www.powershellgallery.com/packages/PSRegexRange)
[![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/PSRegexRange.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)](https://www.powershellgallery.com/packages/PSRegexRange)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1-blue?style=flat&logo=powershell)](https://www.powershellgallery.com/packages/PSRegexRange)
[![PSGallery Platform](https://img.shields.io/powershellgallery/p/PSRegexRange.svg?style=flat&logo=powershell&label=PSGallery%20Platform)](https://www.powershellgallery.com/packages/PSRegexRange)
[![Support Me](https://img.shields.io/badge/Support_Me-Buy_a_Coffee-orange?style=for-the-badge)](https://coff.ee/biereluc)

This module contain functions to convert a numeric range into a regular expression pattern.

## Table of Contents
- [PSRegexRange](#PSRegexRange)
- [Release Notes](#Release-Notes)
- [Install module from the PowerShell Gallery](#Install-module-from-the-PowerShell-Gallery)
- [Usage and Examples](#Usage-and-Examples)
  - [ConvertTo-RegexRange](#ConvertTo-RegexRange)
- [Support](#Support)

# Release Notes
v0.1.0 - Initial release

# Install module from the PowerShell Gallery
If your machine doesn't natively use TLS 1.2, run this first:
```PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

Install module:
```PowerShell
Install-Module PSRegexRange
```
or
```PowerShell
Install-PSResource PSRegexRange
```

# Usage and Examples
Import the module:
```PowerShell
Import-Module PSRegexRange
```
### ConvertTo-RegexRange
Convert a 1 to 100 range into a regular expression pattern with optional zero-padding.
```PowerShell
ConvertTo-RegexRange -Minimum 1 -Maximum 100 -RelaxZeros
```

# Support
I develop most of my code under open licenses, free of charge.
If you are satisfied with these solutions, you can express your [Buy me a coffee](https://coff.ee/biereluc).
The greater your support, the greater the motivation to develop them further. The more motivation, the more things I can create.