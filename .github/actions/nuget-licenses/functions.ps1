function IsDisallowedPackage {
    param(
        [string]$packageName,
        [string]$packageVersion,
        [array]$disallowedPackages
    )
    foreach ($disallowedPackage in $disallowedPackages) {
        if ($disallowedPackage.name -like $packageName) {
            $minVersion = $disallowedPackage.minVersion
            $maxVersion = $disallowedPackage.maxVersion

            if ([string]::IsNullOrEmpty($minVersion) -or [version]$packageVersion -ge [version]$minVersion) {
            if ([string]::IsNullOrEmpty($maxVersion) -or [version]$packageVersion -le [version]$maxVersion) {
                return $true
            }
            }
        }
    }
    return $false
}

function IsAllowedPackage {
    param(
        [string]$packageName,
        [string]$packageVersion,
        [array]$allowedPackages
    )

    foreach ($allowedPackage in $allowedPackages) {
        if ($allowedPackage.name -eq $packageName) {
            $minVersion = $allowedPackage.minVersion
            $maxVersion = $allowedPackage.maxVersion

            if (-not [string]::IsNullOrEmpty($minVersion) -and [version]$packageVersion -lt [version]$minVersion) {
                return $false
            }
            if (-not [string]::IsNullOrEmpty($maxVersion) -and [version]$packageVersion -gt [version]$maxVersion) {
                return $false
            }
            return $true
        }
    }
    return $true
}