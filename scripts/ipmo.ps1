<#
.SYNOPSIS
    Opens a new PowerShell session with a single module loaded.
.DESCRIPTION
    Resolves the path to a module's manifest (.psd1) under the ./modules
    directory, then launches a new interactive PowerShell window with that
    module already imported. The new session is kept open (via -NoExit) so
    one can immediately work with the module's exported commands.

    Useful for quickly testing or exploring a module in isolation, without
    affecting your current session.
.PARAMETER Module
    The name of the module to load. Must match a subdirectory under ./modules
    that contains a matching .psd1 manifest file.
.PARAMETER Function
    pass
.EXAMPLE
    .\Open-ModuleSession.ps1 -Module management -Function cpa
    Opens a new PowerShell window with the function 'cpa' from the module 
    management imported.
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
Start-Process powershell -ArgumentList "-NoExit -NoProfile -Command $command"