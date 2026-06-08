<#
.SYNOPSIS
    Opens a new PowerShell session with a single-module / functions loaded.
.DESCRIPTION
    Resolves the path to a module's manifest (.psd1) under the ./modules
    directory, then launches a new interactive PowerShell window with that
    module (or $Function if specified) already imported. 
    The new session is kept open (via -NoExit) so one can immediately work with 
    the module's exported commands.

    Useful for quickly testing or exploring a module in isolation, without
    affecting your current session.
.PARAMETER Module
    The name of the module to load. Must match a subdirectory under ./modules
    that contains a matching .psd1 manifest file.
.PARAMETER Function
    The actual name of the function to import from the module. When this is set,
    only the list of passed functions is imported from the given module.
.EXAMPLE
    .\Open-ModuleSession.ps1 -Module management -Function Copy-Path
    Opens a new PowerShell window with the function 'Copy-Path' from the module 
    'management' imported.
.EXAMPLE
    .\Open-ModuleSession.ps1 -Module management
    Opens a new PowerShell window with all the functions from the module 
    'management' imported.
#>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $Module,
    [Parameter(Mandatory=$false, ValueFromRemainingArguments)]
    [string[]] $Function
)

$lower = $Module.ToLower()
$p = Resolve-Path "$PSScriptRoot\..\modules\$lower\$lower.psd1"

if (-not (Test-Path $p)) {
    $err = "Wrong Module, path $p does not exist."
    Write-Error -Category InvalidArgument -ErrorAction Stop $err
}

$command = "Import-Module '$p'"

if ($Function) {
    $asArgs = $Function -join ", "
    $command = "$command -Function $asArgs"
}

Start-Process powershell -ArgumentList "-NoExit -NoProfile -Command $command"