param(
    [string] $Module
)

$lower = $Module.ToLower()
$p = Resolve-Path "$PSScriptRoot\..\modules\$lower\$lower.psd1"

if (-not (Test-Path $p)) {
    $err = "Wrong Module, path $p does not exist."
    Write-Error -Category InvalidArgument -ErrorAction Stop $err
}

$command = "Import-Module '$p'"
Start-Process powershell -ArgumentList "-NoExit -NoProfile -Command $command"