Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\sensitive.psm1")

Import-Module (Resolve-Path "$PSScriptRoot\..\style\style.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\prompt\prompt.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\management\management.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\applications\applications.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\time\time.psd1")


function Set-OfficeWorkspace {
    [alias("!office")]
    param (
        
    )
    Get-TimeFromCity -City Chicago
    Set-Location $WorkDirectory
    Open-Zoom
    if (-not (isLightModeEnabled)) {
        Set-LightTheme -ResetExplorer
    } else {
        Write-Host "Light Mode is already enabled."
    }
    $woringkWallpaper = [System.IO.Path]::Combine(
            $env:USERPROFILE, 
            "images", 
            "wallpapers", 
            "working.jpg"
        ) 
    Set-Wallpaper $woringkWallpaper
}

function Set-OutWorkspace {
    [alias("!out")]
    param (
        
    )
    Get-TimeFromCity -City Madrid
    Set-Location $HOME
    if (isLightModeEnabled) {
        Set-DarkTheme -ResetExplorer
    }
    Set-Wallpaper
}