# Secure-by-Design Control Research

A defensive research repository for assessing whether security is built into products, services, and engineering processes from the start.

## Research areas

- Security ownership and design review
- Secure defaults
- Authentication and authorization design
- Logging and monitoring
- Dependency and supply-chain controls
- Vulnerability response
- Data protection and privacy
- Release governance
- Customer security guidance

## Main tool

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Secure_by_Design_Control_Research.ps1 -InputCsv .\research\control-register.csv
```

## Required CSV columns

`Product`, `Owner`, `ControlArea`, `ControlName`, `Implemented`, `DefaultSecure`, `Evidence`, `ReviewFrequency`, `Risk`, `Notes`

## Safety

Assessment and documentation only. No product, repository, or infrastructure settings are changed.
