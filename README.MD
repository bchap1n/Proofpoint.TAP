# Proofpoint TAP powershell module

## Summary

Proofpoint TAP api functions used internally at Proofpoint IT

## What can it do?

Pull all the blocked and permitted clicks from the TAP siem/clickers api by, hour or day up to the maximum 7 days in the past

## Requirements

The module runs on Powershell 7.2 (Core) on Windows OS

## Contributing and Building this Module

This module is built (compiled) with Press.psm1/Invoke-Build on Powershell 7.2+
If you need to make changes, then do a PR and then run the build.ps1 to update the .\BuildOutput.
Press handles updating the module version, notes, tests, and other tasks.
