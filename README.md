# license-check-gha

## NuGet Licenses GitHub Action

This GitHub Action, located at `.github/actions/nuget-licenses`, is designed to check and validate the licenses of NuGet packages used in your project. It ensures compliance with licensing requirements and helps maintain transparency in your dependencies.

### Features

- Scans NuGet packages for license information.
- Validates licenses against a predefined list of acceptable licenses.
- Generates a report summarizing license compliance.

### Inputs

| Name          | Description                              | Required | Default |
|---------------|------------------------------------------|----------|---------|
| `WORKING_DIRECTORY` | Path to the NuGet package configuration file (e.g., `packages.config` or `*.csproj`). | Yes      | N/A     |

### Outputs

| Name           | Description                              |
|----------------|------------------------------------------|
| `licenseReport`| Path to the generated license compliance report. |

### Usage

Below is an example of how to use this action in a workflow:

```yaml
name: License Check

on:
    push:
        branches:
            - main

jobs:
    license-check:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout code
                uses: actions/checkout@v3

            - name: Build project
                run: |
                    dotnet restore
                working-directory: ${{ inputs.WORKING_DIRECTORY }}

            - name: NuGet license check
                uses: ./.github/actions/nuget-licenses
                with:
                    WORKING_DIRECTORY: ${{ inputs.WORKING_DIRECTORY }}
```

### Configuration

By default the Github Action searched for a file called `license-rules.json` in the working directory of the application. The `license-rules.json` file allows you to customize license validation for your project. Here’s an explanation of each setting:

- **allowedLicenses**:  
    An array of license names that are permitted for use. Packages with licenses not listed here will be flagged as non-compliant.

- **disallowedPackages**:  
    A list of specific packages that are not allowed, regardless of their license. Each entry can specify a `name` and an optional `minVersion` and `maxVersion` to block only certain versions or higher.

- **allowedPackages**:  
    A list of package names that are always allowed, even if their license is not in `allowedLicenses`. This is useful for exceptions or internal packages. Each entry can specify a `name` and an optional `minVersion` and `maxVersion` to block only certain versions or higher.

Adjust these settings to match your organization’s compliance requirements.

```json
{
    "allowedLicenses": ["MIT", "Project References", "Apache-2.0", "EULA.md", "Microsoft Software License", "BSD-3-Clause", "EULA-agreement.txt"],
    "disallowedPackages": [
        {
            "name": "Moq",
            "minVersion": "4.20"
        }
    ],
    "allowedPackages": [
        {
            "name": "SixLabors.ImageSharp"
        }
    ]
}
```

### License

This project is licensed under the [MIT License](LICENSE).

### Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.

### Support

If you encounter any issues, feel free to open an issue in the repository.
