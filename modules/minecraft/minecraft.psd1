@{
    ModuleVersion     = '1.0.0'
    RootModule        = 'minecraft.psm1'

    FunctionsToExport = @(
        "Open-FabricAPIInstaller",
        "Move-MinecraftModJars",
        "Switch-MinecraftModVersion"
    )
}