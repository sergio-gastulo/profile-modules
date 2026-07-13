Import-Module "$PSScriptRoot\configs\bindings.psm1"
Import-Module "$PSScriptRoot\configs\variables.psm1"
Import-Module "$PSScriptRoot\configs\sensitive.psm1"

Import-Module "$PSScriptRoot\modules\management\management.psd1"
Import-Module "$PSScriptRoot\modules\prompt\prompt.psd1"
Import-Module "$PSScriptRoot\modules\time\time.psd1" 
Import-Module "$PSScriptRoot\modules\todo\todo.psd1"
Import-Module "$PSScriptRoot\modules\workspace\workspace.psd1"
Import-Module "$PSScriptRoot\modules\applications\applications.psd1"
Import-Module "$PSScriptRoot\modules\style\style.psd1"
Import-Module "$PSScriptRoot\modules\remindme\remindme.psd1"
try {
    Import-Module "$PSScriptRoot\modules\minecraft\minecraft.psd1" -ErrorAction Stop
}
catch {
    Write-Host "An error occurred importing the Minecraft Module:"
    Write-Host $_
    Write-Host "This module has been skipped."
}

function prompt {
    return Get-Prompt
}

Clear-Host