$modulePath = "$PSScriptroot\BuildOutput\Proofpoint.TAP"
Publish-Module -Path $ModulePath -NuGetApiKey $Env:PS_GALLERY_KEY