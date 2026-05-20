function Get-BatteryInfo {
    param (
        
    )
    $battery = (Get-WmiObject -Class Win32_Battery)
    [int] $charge = $battery.EstimatedChargeRemaining
    $battery = (Get-WmiObject -Class BatteryStatus -Namespace "root\wmi")
    [bool] $isCharging = $battery.Charging

    return $charge, $isCharging
}

function Set-BatteryStyle {
    param (
        [double] $charge,
        [bool] $isCharging
    )
    $ESC = [char]27
    $END = "${ESC}[0m"
    $RED = "${ESC}[31m"
    $GREEN = "${ESC}[32m"
    $YELLOW = "${ESC}[33m"

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
    $ESC = [char]27
    $END = "${ESC}[0m"
    $CYAN = "${ESC}[36m"
    $currentDir = Split-Path (Get-Location) -Leaf
    $pathStyled = "$CYAN$currentDir$END"
    return $pathStyled
}

function Set-Prompt {
    param(
        [string] $city = "Madrid"
    )
    $user = $env:USERNAME
    $computer = $env:COMPUTERNAME
	$ssh = "$user@$computer"
    $path = Get-CurrentPathStyled
    $time = Get-Time -city $city -echo $false

    $charge, $isCharging = Get-BatteryInfo 
    $batteryStr = Set-BatteryStyle -charge $charge -isCharging $isCharging


    $promptStr = "PS ($time) ($batteryStr) [$ssh] $path`n> "
    return $promptStr
}

Export-ModuleMember Set-Prompt