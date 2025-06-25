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

### License

This project is licensed under the [MIT License](LICENSE).

### Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.

### Support

If you encounter any issues, feel free to open an issue in the repository.
