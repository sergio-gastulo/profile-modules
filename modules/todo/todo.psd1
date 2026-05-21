@{
    ModuleVersion     = '1.0.0'
    RootModule        = 'todo.psm1'

    FunctionsToExport = @(
        "New-Todo",
        "Search-Todo",
        "Move-Todo",
        "Switch-Todo",
        "Set-Reminder"
    )
}