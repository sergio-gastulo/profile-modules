Import-Module $PSScriptRoot\time.psm1

$ESC = [char]27
$END = "${ESC}[0m"
$RED = "${ESC}[31m"
$GREEN = "${ESC}[32m"
$YELLOW = "${ESC}[33m"
$CYAN = "${ESC}[36m"

function Get-BatteryInfo {
    param (
        
    )
    $battery = (Get-WmiObject -Class Win32_Battery)
    [int] $charge = $battery.EstimatedChargeRemaining
    $battery = (Get-WmiObject -Class BatteryStatus -Namespace "root\wmi")
    [bool] $isCharging = $battery.Charging

    return $charge, $isCharging
}

function Get-BatteryInfoStyled {
    param (
        [double] $charge,
        [bool] $isCharging
    )
    $critical = 20
    $warn = 35
    $chargeFmt = [Math]::Floor($charge)

    if ($isCharging) {
        $chargeStr = "$GREEN$chargeFmt% +"
    } else {
        if ($charge -lt $critical) {
            $chargeStr = "$RED$chargeFmt%"
        } elseif ($charge -lt $warn) {
            $chargeStr = "$YELLOW$chargeFmt%"
        } else {
            $chargeStr = "$chargeFmt%"
        }
    }
    $chargeStr = "$chargeStr$END"
    return $chargeStr
}


function Get-CurrentPathStyled {
    param(

    )
    $currentDir = Split-Path (Get-Location) -Leaf
    $pathStyled = "$CYAN$currentDir$END"
    return $pathStyled
}

function Get-Prompt {
    param(
        [string] $city = $CurrentCity
    )
    $user = $env:USERNAME
    $computer = $env:COMPUTERNAME
	$ssh = "$user@$computer"
    $path = Get-CurrentPathStyled
    $time = Get-TimeFromCity -city $city

    $charge, $isCharging = Get-BatteryInfo 
    $battery = Get-BatteryInfoStyled -charge $charge -isCharging $isCharging

    $promptStr = "PS ($time) ($battery) [$ssh] $path`n> "
    return $promptStr 
}

Export-ModuleMember -Function @(
    "Get-Prompt"
)