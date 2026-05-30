param(
    [string] $Module
)

$lower = $Module.ToLower()
$p = Resolve-Path "$PSScriptRoot\..\modules\$lower\$lower.psd1"

if (-not (Test-Path $p)) {
    Write-Error "Wrong Module, path $p does not exist."
}

$command = "Import-Module '$p'"
Start-Process powershell -ArgumentList "-NoExit -NoProfile -Command $command"