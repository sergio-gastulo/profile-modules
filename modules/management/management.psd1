@{
    ModuleVersion     = '1.0.0'
    RootModule        = 'management.psm1'

    FunctionsToExport = @(
        'Save-ClipboardImage',
        'Copy-Path', 
        'Start-PowershellAdminMode',
        'Set-HideItem',
        'Set-LocationModified',
        'New-TemporaryVimFileEdit',
        'Set-EnvironmentalVariable'
    )
}