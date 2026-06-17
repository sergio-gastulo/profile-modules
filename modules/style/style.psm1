$THEMES_REGISTRY_PATH = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$SHOW_DESKTOP_REGISTRY_PATH ="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$DefaultDarkModeTerminalTheme = "One Half Dark"
$DefaultLightModeTerminalTheme = "One Half Light (Copy)"


$availableThemes = @(
    "CGA",
    "Campbell",
    "Campbell PowerShell",
    "Dark+",
    "Dimidium",
    "IBM 5153",
    "One Half Dark",
    "One Half Light",
    "One Half Light (Copy)",
    "Ottosson",
    "Solarized Dark",
    "Solarized Light",
    "Tango Dark",
    "Tango Light",
    "Vintage"
)


<#
.SYNOPSIS
    List all PowerShell Themes available (manually typed, yes.)
.EXAMPLE
    getpowthemes
#>
function Get-PowerShellThemes {
    [alias("getpowthemes")]
    param (

    )
    Format-Table $availableThemes
}


<#
.SYNOPSIS
    Set PowerShell theme from the same terminal.
.EXAMPLE
    Set-PowerShellTheme -Theme "One Half Dark"
    setpowtheme "One Half Dark"
#>
function Set-PowerShellTheme {
    [alias("setpowtheme")]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Theme
    )

    if (-not ($Theme -in $availableThemes)) {
        Write-Error "Invalid Theme. To check available themes, run 'getpowthemes'." -Category InvalidArgument
        return
    }

	$LocalPowerShellSettings = [System.IO.Path]::Combine(
		${env:LOCALAPPDATA}, 
		"Packages", 
		"Microsoft.WindowsTerminal_8wekyb3d8bbwe",  # is this machine dependent?
		"LocalState", 
		"settings.json"
	)
    # force writing theme to settings.json
    $json = Get-Content $LocalPowerShellSettings | ConvertFrom-Json
    $json.profiles.list[0].colorScheme = $Theme
    $json.profiles.list[1].colorScheme = $Theme
    $json | ConvertTo-Json -depth 100 | Set-Content $LocalPowerShellSettings
}


function killExplorerAndRestart {
    # apparently pwsh restarts the process automatically (tested)
    # https://www.reddit.com/r/PowerShell/comments/1cgv34l/comment/l1ygply
    $process = "explorer"
    Get-Process -Name $process | Stop-Process -Force
}


<#
.SYNOPSIS
    Set Computer theme to Dark.
.LINK
    https://gist.github.com/bobby-tablez/4b5f1ee02c68a93dc8312c4ff858c0a7
.EXAMPLE
    Set-DarkTheme -ResetExplorer -Seconds 2 -PowerShellTheme "IBM 5153"
    Sets dark theme for the computer, kills and respawns explorer.exe after two 
    seconds and sets PowerShell theme to "IBM 5153."
.EXAMPLE
    darkmode
    Sets dark theme for the computer and sets PowerShell theme to 
    $DefaultDarkModeTerminalTheme.
#>
function Set-DarkTheme {
    [alias("darkmode")]
    param(
        [switch] $ResetExplorer,
        [int] $Seconds = 1,
        [string] $PowerShellTheme = $DefaultDarkModeTerminalTheme
    )
    Set-ItemProperty -Path $THEMES_REGISTRY_PATH -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $THEMES_REGISTRY_PATH -Name "SystemUsesLightTheme" -Value 0
    Set-PowerShellTheme $DefaultDarkModeTerminalTheme
    if ($ResetExplorer) {
        killExplorerAndRestart -Seconds $Seconds
    }
    Write-Host "Dark theme enabled."
}


<#
.SYNOPSIS
    Set Computer theme to Light.
.LINK
    https://gist.github.com/bobby-tablez/4b5f1ee02c68a93dc8312c4ff858c0a7
.EXAMPLE
    Set-LightTheme -ResetExplorer -Seconds 2 -PowerShellTheme "IBM 5153"
    Sets light theme for the computer, kills and respawns explorer.exe after two 
    seconds and sets PowerShell theme to "IBM 5153."
.EXAMPLE
    lightmode
    Sets Light theme for the computer and sets PowerShell theme to 
    $DefaultLightModeTerminalTheme.
#>
function Set-LightTheme {
    [alias("lightmode")]
    param(
        [switch] $ResetExplorer,
        [int] $Seconds = 1,
        [string] $PowerShellTheme = $DefaultLightModeTerminalTheme
    )
    Set-ItemProperty -Path $THEMES_REGISTRY_PATH -Name "AppsUseLightTheme" -Value 1
    Set-ItemProperty -Path $THEMES_REGISTRY_PATH -Name "SystemUsesLightTheme" -Value 1
    Set-PowerShellTheme $DefaultLightModeTerminalTheme
    if ($ResetExplorer) {
        killExplorerAndRestart -Seconds $Seconds
    }
    Write-Host "Light theme enabled."
}


<#
.SYNOPSIS
    Check if system has light mode enabled.
.EXAMPLE
    isLightModeEnabled      # True/False
#>
function isLightModeEnabled {
    param (
        
    )
    $registry = Get-ItemProperty -Path $THEMES_REGISTRY_PATH
    $appsInLightMode = $registry.AppsUseLightTheme
    $systemInLightMode = $registry.SystemUsesLightTheme
    return ($appsInLightMode -and $systemInLightMode)
}

function getRandomWallpaper {
        # https://www.reddit.com/r/PowerShell/comments/wpgjyc/comment/ikgojkg
        $wallpapersPath = [System.IO.Path]::Combine(
            $env:USERPROFILE, 
            "images", 
            "wallpapers", 
            "real_wallpapers"
        )
        $wallpapers = Get-ChildItem -Path $wallpapersPath 
        $wallpaperPath = ($wallpapers | Get-Random).FullName
        return $wallpaperPath
}

function setWallpaper {
    param([string] $wallpaper)
    # addapted from
    # https://github.com/fleschutz/PowerShell/blob/main/scripts/set-wallpaper.ps1
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(
                int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@

    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE   = 0x01
    $SPIF_SENDCHANGE      = 0x02

    [Wallpaper]::SystemParametersInfo(
        $SPI_SETDESKWALLPAPER,
        0,
        $wallpaper,
        $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE
    ) | Out-Null
}


<#
.SYNOPSIS
    Set wallpaper from command line.
.DESCRIPTION
    If no wallpaper path is provided, it will randomly fetch from 
    $HOME\images\wallpapers\real_wallpapers.
.LINK
    # https://github.com/fleschutz/PowerShell/blob/main/scripts/set-wallpaper.ps1
.EXAMPLE
    Set-Wallpaper foo.png
#>
function Set-Wallpaper {
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string] $WallpaperPath,
        [switch] $Random
    )
    if (-not $WallpaperPath) {
        if ($Random) {
            $WallpaperPath = getRandomWallpaper
        } else {
            $err = "No path provided to Wallpaper. Enable -Random flag."
            Write-Error -ErrorAction Stop -Category InvalidArgument -Message $err
        }
    }
    $resolved = Resolve-Path $WallpaperPath
	if (-not (Test-Path $resolved)) {
		Write-Error -Category InvalidArgument -Message "Path '$resolved' is invalid."
		return
	}
    setWallpaper $resolved
}


function Show-DesktopIcons {
    param(
        [switch] $DontKillExplorer
    )
    # https://superuser.com/a/1480904/2665716
    Set-ItemProperty -Path $SHOW_DESKTOP_REGISTRY_PATH -Name "HideIcons" -Value 0
    if (-not $DontKillExplorer) {
        killExplorerAndRestart
    }
}

function Hide-DesktopIcons {
    param(
        [switch] $DontKillExplorer
    )
    # https://superuser.com/a/1480904/2665716
    Set-ItemProperty -Path $SHOW_DESKTOP_REGISTRY_PATH -Name "HideIcons" -Value 0
    if (-not $DontKillExplorer) {
        killExplorerAndRestart
    }
}