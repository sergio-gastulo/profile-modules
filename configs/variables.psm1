[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

# custom variables that do not leak sensitive information
$MinecraftPath = [System.IO.Path]::Combine($env:APPDATA, ".minecraft")
$VenvPythonExecutable = [IO.Path]::Combine(
    $PSScriptRoot, 
    "..", 
    ".venv", 
    "Scripts", 
    "python.exe")

Export-ModuleMember -Variable @(
    "MinecraftPath",
    "VenvPythonExecutable"
)