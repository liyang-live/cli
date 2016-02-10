#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

param(
    [string]$Configuration="Debug",
    [switch]$Offline,
    [switch]$NoPackage)

$ErrorActionPreference="Stop"

. "$PSScriptRoot\..\common\_common.ps1"

. "$RepoRoot\scripts\build\generate-version.ps1"

_ "$RepoRoot\scripts\clean\clear-nuget-cache.ps1"

header "Building dotnet tools version $($env:DOTNET_CLI_VERSION) - $Configuration"
header "Checking Pre-Reqs"

_ "$RepoRoot\scripts\test\check-prereqs.ps1"

header "Restoring Tools and Packages"

if ($Offline){
    info "Skipping Tools and Packages dowlnoad: Offline build"
}
else {
    _ "$RepoRoot\scripts\obtain\install-tools.ps1"
}

header "Cleaning out .ni's from Stage0"
rm "$RepoRoot\.dotnet_stage0\**\*.ni.*"

_ "$RepoRoot\scripts\build\restore-packages.ps1"

header "Compiling"
_ "$RepoRoot\scripts\compile\compile.ps1" @("$Configuration")

header "Setting Stage2 as PATH and DOTNET_TOOLS"
setPathAndHome "$Stage2Dir"

header "Testing"
_ "$RepoRoot\scripts\test\test.ps1"

header "Validating Dependencies"
_ "$RepoRoot\scripts\test\validate-dependencies.ps1"

if ($NoPackage){
    info "Skipping Packaging"
    exit 0
}
else {
    _ "$RepoRoot\scripts\package\package.ps1"
}
