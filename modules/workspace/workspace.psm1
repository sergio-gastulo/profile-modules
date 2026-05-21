Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\sensitive.psm1")

Import-Module (Resolve-Path "$PSScriptRoot\..\style\style.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\prompt\prompt.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\management\management.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\applications\applications.psd1")
Import-Module (Resolve-Path "$PSScriptRoot\..\time\time.psd1")


function Set-OfficeWorkspace {
    param (
        
    )
    Set-TimeFromCity -City Chicago -Echo
    Set-Location $WorkDirectory
    Open-Zoom
    if (-not (isLightModeEnabled)) {
        Set-LightTheme
    }
    $woringkWallpaper = Join-Path -Path $WallPaperImagesDirectory -ChildPath "working.jpg" 
    Set-Wallpaper $woringkWallpaper
}

function Set-OutWorkspace {
    param (
        
    )
    Set-TimeFromCity -City Madrid -Echo
    Set-Location $HOME
    if (isLightModeEnabled) {
        Set-DarkTheme        
    }
    Set-Wallpaper
}


function Switch-Workspace {
    [alias("switchworkspace")]
    param(
        [switch] $office,
        [switch] $out
    )

    if (-not ($office -xor $out)) {
        Write-Error -Category InvalidArgument -Message "Only one mode at a time can be passed."
        return
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