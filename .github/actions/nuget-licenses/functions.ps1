function ContainsPackage {
    param(
        [string]$packageName,
        [string]$packageVersion,
        [array]$packages
    )

    if (-not $packageName -or -not $packageVersion -or -not $packages) {
        return $false
    }

    foreach ($package in $packages) {
        if ($package.name -eq $packageName) {
            $minVersion = $package.minVersion
            $maxVersion = $package.maxVersion

            if (-not [string]::IsNullOrEmpty($minVersion) -and [version]$packageVersion -lt [version]$minVersion) {
                return $false
            }
            if (-not [string]::IsNullOrEmpty($maxVersion) -and [version]$packageVersion -gt [version]$maxVersion) {
                return $false
            }
            return $true
        }
    }
    return $false
}