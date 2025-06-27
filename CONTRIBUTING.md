# Contributing

## Unit testing

Run this command to run the unit tests. For the tests we use pester

```pwsh
Invoke-Pester -Path ".github/actions/nuget-licenses" -OutputFormat NUnitXml -OutputFile ".github/actions/nuget-licenses/test-results.xml" -PassThru | Select-Object -Property Name, Result, Duration | Format-Table -AutoSize
```

## Test process script with the sample application

Run this command to run the licensing script

```pwsh
.github/actions/nuget-licenses/process.ps1 -workingDir "./samples/basic/simpleConsoleApplication"                          
```