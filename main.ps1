Import-Module "$PSScriptRoot\scripts\time.psm1"
Import-Module "$PSScriptRoot\scripts\prompt-utils.psm1"
Import-Module "$PSScriptRoot\scripts\file-management.psm1"


function prompt {
    if ($Global:City) {
        $str = Set-Prompt -city $Global:City
    } else {
        $Global:City = "Madrid"
        $str = Set-Prompt
    }
    return $str
}