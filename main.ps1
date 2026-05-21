Import-Module "$PSScriptRoot\scripts\bindings.psm1"
Import-Module "$PSScriptRoot\scripts\management.psm1"
Import-Module "$PSScriptRoot\scripts\prompt.psm1"
Import-Module "$PSScriptRoot\scripts\time.psm1"
Import-Module "$PSScriptRoot\scripts\todo.psm1"
Import-Module "$PSScriptRoot\scripts\variables.psm1"
Import-Module "$PSScriptRoot\scripts\workspace.psm1"

Set-Alias -Name "ss" -Value Save-ClipboardImage

function prompt {
    $str = Get-Prompt -city $CurrentCity
    return $str
}