Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\sensitive.psm1")

Import-Module (Resolve-Path "$PSScriptRoot\..\style\style.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\prompt\prompt.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\management\management.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\applications\applications.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\time\time.psd1")


function Set-OfficeWorkspace {
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
    param (
        
    )
    Get-TimeFromCity -City Madrid
    Set-Location $HOME
    if (isLightModeEnabled) {
        Set-DarkTheme -ResetExplorer
    }
    Set-Wallpaper
}


function Switch-Workspace {
    [alias("!workspace")]
    param(
        [switch] $office,
        [switch] $out
    )

    if (-not ($office -xor $out)) {
        Write-Error -Category InvalidArgument -Message "Only one mode at a time can be passed." -ErrorAction Stop
    }

    if ($office) {
        Set-OfficeWorkspace
        return
    }
    if ($out) {
        Set-OutWorkspace
        return
    }

}