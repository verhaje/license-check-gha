# Contributing

## Unit testing

Run this command to run the unit tests. For the tests we use pester

```pwsh
Invoke-Pester -Path ".github/actions/nuget-licenses" -OutputFormat NUnitXml -OutputFile ".github/actions/nuget-licenses/test-results.xml" -PassThru | Select-Object -Property Name, Result, Duration | Format-Table -AutoSize
```