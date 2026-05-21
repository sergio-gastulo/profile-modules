Import-Module $PSScriptRoot\style.psm1
Import-Module $PSScriptRoot\sensitive.psm1
Import-Module $PSScriptRoot\prompt.psm1
Import-Module $PSScriptRoot\management.psm1
Import-Module $PSScriptRoot\applications.psm1
Import-Module $PSScriptRoot\time.psm1


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

    if ($office -xor $out) {
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

Export-ModuleMember -Function Switch-Workspace