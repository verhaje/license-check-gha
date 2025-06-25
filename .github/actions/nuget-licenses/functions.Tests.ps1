BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}
Describe "IsAllowedPackage" {
    Context "Allowed Packages" {
        It "Returns $true for a package within allowed version range" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $disallowedPackages = @()
            $result = IsAllowedPackage -packageName "TestPackage" -packageVersion "1.5.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $true
        }

        It "Returns $true for a package within allowed version range and only minVersion" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                }
            )
            $disallowedPackages = @()
            $result = IsAllowedPackage -packageName "TestPackage" -packageVersion "1.5.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $true
        }

        It "Returns $true for a package within allowed version range and only minVersion" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    maxVersion = "2.0.0"
                }
            )
            $disallowedPackages = @()
            $result = IsAllowedPackage -packageName "TestPackage" -packageVersion "1.5.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $true
        }

        It "Returns $false for a package below allowed version range" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $disallowedPackages = @()
            $result = IsAllowedPackage -packageName "TestPackage" -packageVersion "0.9.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $false
        }

        It "Returns $true for a package when no range is defined" {
            $allowedPackages = @()
            $disallowedPackages = @(
                @{
                    name = "TestPackage"
                }
            )
            $result = IsAllowedPackage -packageName "TestPackage" -packageVersion "1.5.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $true
        }

        It "Returns $false for a package above allowed version range" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $disallowedPackages = @()
            $result = IsAllowedPackage -packageName "TestPackage" -packageVersion "2.1.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $false
        }
    }

    Context "Disallowed Packages" {
        It "Returns $true for a package within disallowed version range" {
            $allowedPackages = @()
            $disallowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $result = IsDisallowedPackage -packageName "TestPackage" -packageVersion "1.5.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $true
        }

        It "Returns $true for a package when no range is defined" {
            $allowedPackages = @()
            $disallowedPackages = @(
                @{
                    name = "TestPackage"
                }
            )
            $result = IsDisallowedPackage -packageName "TestPackage" -packageVersion "1.5.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $true
        }

        It "Returns $false for a package outside disallowed version range" {
            $allowedPackages = @()
            $disallowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $result = IsDisallowedPackage -packageName "TestPackage" -packageVersion "2.1.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $false
        }
    }

    Context "Unlisted Packages" {
        It "Returns $false for a package not listed in allowed packages" {
            $allowedPackages = @()
            $disallowedPackages = @()
            $result = IsAllowedPackage -packageName "UnlistedPackage" -packageVersion "1.0.0" -allowedPackages $allowedPackages -disallowedPackages $disallowedPackages
            $result | Should -Be $false
        }
    }
}