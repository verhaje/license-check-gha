BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}
Describe "Package Validation Functions" {
    Context "Contains package" {
        It "Returns $true for a package within allowed version range" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $result =  ContainsPackage -packageName "TestPackage" -packageVersion "1.5.0" -packages $allowedPackages
            $result | Should -Be $true
        }

        It "Returns $true for a package within allowed version range and only minVersion" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                }
            )
            $result =  ContainsPackage -packageName "TestPackage" -packageVersion "1.5.0" -packages $allowedPackages
            $result | Should -Be $true
        }

        It "Returns $true for a package within allowed version range and only minVersion" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    maxVersion = "2.0.0"
                }
            )
            $result =  ContainsPackage -packageName "TestPackage" -packageVersion "1.5.0" -packages $allowedPackages
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
            $result = ContainsPackage -packageName "TestPackage" -packageVersion "0.9.0" -packages $allowedPackages
            $result | Should -Be $false
        }

        It "Returns $true for a package when no range is defined" {
            $disallowedPackages = @(
                @{
                    name = "TestPackage"
                }
            )
            $result = ContainsPackage -packageName "TestPackage" -packageVersion "1.5.0" -packages $disallowedPackages
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
            $result = ContainsPackage -packageName "TestPackage" -packageVersion "2.1.0" -packages $allowedPackages
            $result | Should -Be $false
        }

        It "Returns $true for a package with exact maxVersion" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $result = ContainsPackage -packageName "TestPackage" -packageVersion "2.0.0" -packages $allowedPackages
            $result | Should -Be $true
        }

        It "Returns $true for a package with exact minVersion" {
            $allowedPackages = @(
                @{
                    name = "TestPackage"
                    minVersion = "1.0.0"
                    maxVersion = "2.0.0"
                }
            )
            $result = ContainsPackage -packageName "TestPackage" -packageVersion "1.0.0" -packages $allowedPackages
            $result | Should -Be $true
        }
    }

    Context "Unlisted Packages" {
        It "Returns $false for a package not listed in allowed packages" {
            $allowedPackages = @()
            $result = ContainsPackage -packageName "UnlistedPackage" -packageVersion "1.0.0" -packages $allowedPackages
            $result | Should -Be $false
        }
    }
}