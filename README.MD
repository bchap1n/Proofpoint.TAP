# Proofpoint TAP powershell module

## Summary

Proofpoint TAP api functions
<https://help.proofpoint.com/Threat_Insight_Dashboard/API_Documentation/People_API>

I only have only added functions for the SIEM_API/clicks at this point.
The next thing I will add is stuff for the People/VAP (/v2/people/vap) and more SIEM stuff.

## What can it do?

SIEM_API:

<https://help.proofpoint.com/Threat_Insight_Dashboard/API_Documentation/SIEM_API>
Pull all the blocked and permitted clicks from the TAP siem/clickers api by, hour or day up to the maximum 7 days in the past

## Requirements

The module runs on Powershell 7.2 (Core) on Windows OS.

## Contributing and Building this Module

I am new to Github and publishing powershell modules so please be patient.

This module is built (compiled) with Press.psm1/Invoke-Build on Powershell 7.2+
Press handles updating the build (BuildOutput), module version, notes, tests, and other tasks.
I have not been able to get Press to build in Github Actions, so I am doing the build locally in devcontainer and removed the .gitignore for BuildOutput.
If you want to do a PR for something don't include any changes to BuildOutput. I will do the build, test, and publish after accepting the PR.
