param(
    [string]$workingDir = "$(Get-Location)",
    [bool]$failOnInvalidLicenses = $false
)

. "$PSScriptRoot\functions.ps1"

Write-Output "Project: $($workingDir)"

# Check if the dotnet application has been built, else build it
$sanitizedWorkingDir = $workingDir -replace '"', ''
if (-not (Test-Path -Path $sanitizedWorkingDir -PathType Container)) {
    Write-Output "Directory '$sanitizedWorkingDir' does not exist. Exiting."
    [Environment]::Exit(1)
}
Set-Location -Path $sanitizedWorkingDir
$rootJson = dotnet-delice -j
$root = $rootJson | ConvertFrom-Json

# Default allowed and disallowed licenses and packages
$allowedLicenses = @("MIT", "Project References", "Apache-2.0", "EULA.md", "Microsoft Software License", "BSD-3-Clause")

# Read license and package rules from a JSON file
$rulesPath = "license-rules.json"
Write-Output "Loading configuration from $($rulesPath)"
if (Test-Path $rulesPath) {
    Write-Output "Loaded configuration from $($rulesPath)"
    $rulesJson = Get-Content $rulesPath -Raw | ConvertFrom-Json

    $allowedLicenses = $rulesJson.allowedLicenses
    $disallowedLicenses = $rulesJson.disallowedLicenses
    $allowedPackages = $rulesJson.allowedPackages
    $disallowedPackages = $rulesJson.disallowedPackages | ForEach-Object {
        $_ | Select-Object -Property name, minVersion, maxVersion
    }
    $allowedPackages = $rulesJson.allowedPackages | ForEach-Object {
        $_ | Select-Object -Property name, minVersion, maxVersion
    }
}

$allowedLicenseCount = 0
$disallowedLicenseCount = 0
$disallowedPackageCount = 0
$licensesMarkdown = ""

Write-Output $rootJson

foreach ($project in $root.projects) {
    $projectName = $project.projectName
    foreach ($license in $project.licenses) {
        # Handle multiple licenses in the expression separated by 'AND'
        $expressions = $license.expression -split '\s+AND\s+' | ForEach-Object { $_.Trim() }
        foreach ($expression in $expressions) {
            if ($allowedLicenses -notcontains $expression -or $disallowedLicenses -contains $expression) {
                $disallowedLicenseMarkdown = ""
                $hasDisallowedPackage = $false
                $disallowedLicenseMarkdown += "### $($projectName): $($expression)`n"
                $disallowedLicenseMarkdown += "Not allowed licenses found in these packages:`n"
                foreach ($package in $license.packages)
                {
                    $packageName = $package.name
                    $packageVersion = $package.version
                    if(IsAllowedPackage -packageName $packageName -packageVersion $packageVersion -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages -and -not IsDisallowedPackage -packageName $packageName -packageVersion $packageVersion -disallowedPackages $disallowedPackages) {
                        $allowedPackagesCount += 1
                    }
                    else {
                        $disallowedPackageCount += 1
                        $hasDisallowedPackage = $true
                        $disallowedLicenseMarkdown += " - $($packageName) $($packageVersion)`n"
                    }
                }
                if ($hasDisallowedPackage) {
                    # disallowed license is only disallowed if it contains packages
                    $disallowedLicenseCount += 1
                    Write-Output "Disallowed license found in project '$($projectName)' with license: $($expression)" 
                    $licensesMarkdown += $disallowedLicenseMarkdown
                }                
            }
            else {
                # Check here if the license is allowed and if it contains disallowed packages
                foreach ($package in $license.packages)
                {
                    $packageName = $package.name
                    $packageVersion = $package.version
                    if (Test-PackageVersion -packageName $packageName -packageVersion $packageVersion -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages) {
                        Write-Output "Disallowed packages found in project '$($projectName)' with license: $($expression)" 
                        $licensesMarkdown += "`n### $($projectName): $($expression)`n"
                        $licensesMarkdown += "Not allowed packages:`n"
                        $licensesMarkdown += " - $($packageName) [$($packageVersion)]`n"
                        $disallowedPackageCount += 1
                    }
                    else {
                        $allowedPackagesCount += 1
                    }
                }
                $allowedPackagesCount += $license.packages.Count
                $allowedLicenseCount +=1
            }
        }
    }
}

Write-Output "Allowed licenses found: $($allowedLicenseCount) "
Write-Output "Non allowed licenses found: $($disallowedLicenseCount)"

# Write information to the GitHub job summary
$summaryFile = $env:GITHUB_STEP_SUMMARY
if (-not [string]::IsNullOrEmpty($summaryFile)) {
    $result = $disallowedLicenseCount -eq 0 ? "✅" : "❌"
    Add-Content -Path $summaryFile -Value "# [$($result)] Licenses Report"
    Add-Content -Path $summaryFile -Value "`n- Allowed licenses found: $($allowedLicenseCount)"
    Add-Content -Path $summaryFile -Value "`n- Non-allowed licenses found: $($disallowedLicenseCount)"
    Add-Content -Path $summaryFile -Value "`n- Allowed packages found: $($allowedPackagesCount)"
    Add-Content -Path $summaryFile -Value "`n- Non-allowed packages found: $($disallowedPackageCount)"

    if (-not [string]::IsNullOrEmpty($licensesMarkdown)) {
        Add-Content -Path $summaryFile -Value "`n## Violations"
        Add-Content -Path $summaryFile -Value "`n$($licensesMarkdown)"
    }

    
    Add-Content -Path $summaryFile -Value "`n## Licenses summary"
    foreach ($project in $root.projects)
    {
        Add-Content -Path $summaryFile -Value "`n**$($project.projectName)**`n"
        foreach ($license in $project.licenses)
        {
            Add-Content -Path $summaryFile -Value "`n- $($license.expression) [$($license.count) packages]"
        }
    }  
} else {
    Write-Output "GitHub job summary file not found."
}

if ($failOnInvalidLicenses -and $disallowedLicenseCount -gt 0) {
    [Environment]::Exit(1603)
}
