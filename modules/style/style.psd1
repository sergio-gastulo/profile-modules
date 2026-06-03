@{
    ModuleVersion     = '1.0.0'
    RootModule        = 'style.psm1'

    FunctionsToExport = @(
        "Set-DarkTheme",
        "Set-LightTheme",
        "Set-Wallpaper",
        "Get-PowerShellThemes",
        "Set-PowerShellTheme",
        "isLightModeEnabled"
    )
}