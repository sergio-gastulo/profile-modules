$THEMESREGISTRYPATH = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$DefaultDarkModeTerminalTheme = "One Half Dark"
$DefaultLightModeTerminalTheme = "One Half Light (Copy)"

$availableThemes = @(
    "CGA",
    "Campbell",
    "Campbell Powershell",
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

function Get-PowershellThemes {
    [alias("getpowthemes")]
    param (

    )
    Format-Table $availableThemes
}

function Set-PowershellTheme {
    [alias("setpowtheme")]
    param (
        [string] $theme
    )

    if (-not ($theme -in $availableThemes)) {
        Write-Error "Invalid Theme. To check available themes, run 'getpowthemes'." -Category InvalidArgument
        return
    }

	$LocalPowershellSettings = [System.IO.Path]::Combine(
		${env:LOCALAPPDATA}, 
		"Packages", 
		"Microsoft.WindowsTerminal_8wekyb3d8bbwe",  # is this machine dependent?
		"LocalState", 
		"settings.json"
	)
    # force writing theme to settings.json
    $json = Get-Content $LocalPowershellSettings | ConvertFrom-Json
    $json.profiles.list[0].colorScheme = $theme
    $json.profiles.list[1].colorScheme = $theme
    $json | ConvertTo-Json -depth 100 | Set-Content $LocalPowershellSettings
}

function Set-DarkTheme {
    Set-ItemProperty -Path $THEMESREGISTRYPATH -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $THEMESREGISTRYPATH -Name "SystemUsesLightTheme" -Value 0
    Set-PowershellTheme $DefaultDarkModeTerminalTheme
    Write-Host "Dark theme enabled."
}

function Set-LightTheme {
    Set-ItemProperty -Path $THEMESREGISTRYPATH -Name "AppsUseLightTheme" -Value 1
    Set-ItemProperty -Path $THEMESREGISTRYPATH -Name "SystemUsesLightTheme" -Value 1
    Set-PowershellTheme $DefaultLightModeTerminalTheme
    Write-Host "Light theme enabled."
}

# TODO: expose only if required (not on global)
function isLightModeEnabled {
    param (
        
    )
    $registry = Get-ItemProperty -Path $THEMESREGISTRYPATH
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

function Set-Wallpaper {
    param(
        [string] $wallpaper
    )
    if (-not $wallpaper) {
        $wallpaper = getRandomWallpaper
    }
    $resolved = Resolve-Path $wallpaper
    setWallpaper $resolved
}