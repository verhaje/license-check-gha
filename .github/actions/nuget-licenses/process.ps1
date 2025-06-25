param(
    [string]$workingDir = "$(Get-Location)",
    [bool]$failOnInvalidLicenses = $false
)

. "$PSScriptRoot/functions.ps1"

Write-Output "Project: $($workingDir)"

# Check if the dotnet application has been built, else build it
$sanitizedWorkingDir = $workingDir -replace '"', ''
if (-not (Test-Path -Path $sanitizedWorkingDir -PathType Container)) {
    Write-Output "Directory '$sanitizedWorkingDir' does not exist. Exiting."
    [Environment]::Exit(1)
}

$rootJson = dotnet-delice -j "$($sanitizedWorkingDir)"
$root = $rootJson | ConvertFrom-Json

# Default allowed licenses
$allowedLicenses = @("MIT", "Project References", "Apache-2.0", "EULA.md", "Microsoft Software License", "BSD-3-Clause")

# Read license and package rules from a JSON file
$rulesPath = Join-Path -Path $sanitizedWorkingDir -ChildPath "/license-rules.json"
if (Test-Path $rulesPath) {
    Write-Output "Loaded configuration from $($rulesPath)"
    $rulesJson = Get-Content $rulesPath -Raw | ConvertFrom-Json

    $allowedLicenses = $rulesJson.allowedLicenses
    $allowedPackages = $rulesJson.allowedPackages
    $disallowedPackages = $rulesJson.disallowedPackages | ForEach-Object {       
        [PSCustomObject]@{
            name       = $_.name
            minVersion = $_.minVersion
            maxVersion = $_.maxVersion
        }
    }
    $allowedPackages = $rulesJson.allowedPackages | ForEach-Object {
        [PSCustomObject]@{
            name       = $_.name
            minVersion = $_.minVersion
            maxVersion = $_.maxVersion
        }
    }
}

$allowedLicenseCount = 0
$disallowedLicenseCount = 0
$disallowedPackageCount = 0
$allowedPackagesCount = 0
$licensesMarkdown = ""

Write-Output $rootJson

foreach ($project in $root.projects) {
    $projectName = $project.projectName
    foreach ($license in $project.licenses) {
        # Handle multiple licenses in the expression separated by 'AND'
        $expressions = $license.expression -split '\s+AND\s+' | ForEach-Object { $_.Trim() }
        foreach ($expression in $expressions) {
            if ($allowedLicenses -contains $expression) {
                $disallowedLicenseMarkdown = ""
                $hasDisallowedPackage = $false
                $hasAtLeastOneAllowedPackage = $false
                $disallowedLicenseMarkdown += "### $($projectName): $($expression)`n"
                $disallowedLicenseMarkdown += "Not allowed licenses found in these packages:`n"
                foreach ($package in $license.packages)
                {
                    $packageName = $package.name
                    $packageVersion = $package.version
                    $isDisallowed = ContainsPackage -packageName $packageName -packageVersion $packageVersion -packages $disallowedPackages
                    if ($isDisallowed) {
                        $disallowedPackageCount += 1
                        $hasDisallowedPackage = $true
                        Write-Output "Disallowed package '$($packageName)' with version '$($packageVersion)' found in project '$($projectName)'"
                        $disallowedLicenseMarkdown += " - $($packageName) $($packageVersion)`n"
                    }
                    else {
                        $hasAtLeastOneAllowedPackage = $true
                        $allowedPackagesCount += 1
                    }
                }
                if ($hasDisallowedPackage) {
                    # disallowed license is only disallowed if it contains packages
                    $disallowedLicenseCount += 1
                    Write-Output "Disallowed license found in project '$($projectName)' with license: $($expression)" 
                    $licensesMarkdown += $disallowedLicenseMarkdown
                }

                if($hasAtLeastOneAllowedPackage) {
                    $allowedLicenseCount += 1
                }
            }
            # Licenses that are not in the allowed list
            else {
                # Check here if the licenses contains allowed packages
                foreach ($package in $license.packages)
                {
                    $packageName = $package.name
                    $packageVersion = $package.version
                    $isAllowedPackage = ContainsPackage -packageName $packageName -packageVersion $packageVersion -packages $allowedPackages
                    if ($isAllowedPackage) {
                        $allowedPackagesCount += 1
                    }
                    else {
                        $licensesMarkdown += "`n### $($projectName): $($expression)`n"
                        $licensesMarkdown += "Not allowed packages:`n"
                        $licensesMarkdown += " - $($packageName) [$($packageVersion)]`n"
                        $disallowedPackageCount += 1

                    }
                }
                $allowedPackagesCount += $license.packages.Count
                $disallowedLicenseCount += 1
            }
        }
    }
}

Write-Output "Allowed licenses found: $($allowedLicenseCount) "
Write-Output "Not allowed licenses found: $($disallowedLicenseCount)"

# Write information to the GitHub job summary
$summaryFile = $env:GITHUB_STEP_SUMMARY
if (-not [string]::IsNullOrEmpty($summaryFile)) {
    $result = $disallowedLicenseCount -eq 0 ? "✅" : "❌"
    Add-Content -Path $summaryFile -Value "# [$($result)] Licenses Report"
    Add-Content -Path $summaryFile -Value "`n- Allowed licenses found: $($allowedLicenseCount)"
    Add-Content -Path $summaryFile -Value "`n- Not allowed licenses found: $($disallowedLicenseCount)"
    Add-Content -Path $summaryFile -Value "`n- Allowed packages found: $($allowedPackagesCount)"
    Add-Content -Path $summaryFile -Value "`n- Not allowed packages found: $($disallowedPackageCount)"

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
            $isOsi = $license.isOsi ? "": " [⚠](https://opensource.org/) Not OSI"
            $isFsf = $license.isFsf ? "": " [⚠](https://www.fsf.org/) Not FSF"
            Add-Content -Path $summaryFile -Value "`n- $($license.expression) [$($license.count) packages]"
            Add-Content -Path $summaryFile -Value $isOsi
            Add-Content -Path $summaryFile -Value $isFsf
        }
    }  
} else {
    Write-Output "GitHub job summary file not found."
}

if ($failOnInvalidLicenses -and $disallowedLicenseCount -gt 0) {
    [Environment]::Exit(1603)
}
