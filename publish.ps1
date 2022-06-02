
# Build the module with Press first, then publish via manual Github Action trigger on main
$modulePath = "$PSScriptroot\BuildOutput\Proofpoint.TAP"
Publish-Module -Path $ModulePath -NuGetApiKey $Env:PS_GALLERY_KEY