
Import-Module (Resolve-Path "$PSScriptRoot\..\time\time.psd1")

$CSPath = [System.IO.Path]::Combine(
    $PSScriptRoot,
    "remindme.cs"
)
$SourceCode = Get-Content $CSPath -Raw

Add-Type -TypeDefinition $SourceCode -ReferencedAssemblies (
    [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework").Location,
    [System.Reflection.Assembly]::LoadWithPartialName("PresentationCore").Location,
    [System.Reflection.Assembly]::LoadWithPartialName("WindowsBase").Location,
    [System.Reflection.Assembly]::LoadWithPartialName("System.Xaml").Location
)

function Set-Reminder {
    [alias("remindme")]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [double] $Minutes,        
        [Parameter(Mandatory=$true, ValueFromRemainingArguments)]
        [string[]] $ReminderMessage
    )
    
    $message = $ReminderMessage -join " "
    $seconds = $Minutes * 60
    [RemindMe.App]::Launch($seconds, $message)

    $when = Get-TimeFromCity -City $CurrentCity -NoEcho -ErrorAction Stop
    $when = $when.AddMinutes($Minutes).ToString("HH:mm:ss")

    Write-Host "Timer set -- reminder at $when (job id: $jid)"

}

