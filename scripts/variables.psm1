[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

# custom variables that do not leak sensitive information
$MinecraftPath = [System.IO.Path]::Combine($env:APPDATA, ".minecraft")

Export-ModuleMember -Variable @(
    "MinecraftPath"
)