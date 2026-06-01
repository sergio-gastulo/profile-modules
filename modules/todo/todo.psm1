Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\sensitive.psm1")
Import-Module (Resolve-Path "$PSScriptRoot\..\time\time.psd1")

function New-Todo {
    [alias("ntodo")]
    param(
        [string] $suffix
    )
	if (-not $suffix) {
		$date = (Get-Date).ToString("yyyy-MM-dd")
	}
    $name = ("todo-" + $date)

	if (Test-Path $name) {
		Write-Error -Message "File already exists. Consider running todo -move." -Category InvalidArgument
		return
	}
	New-Item -Name $name -ItemType "File" | Out-Null
	vim.exe $name
}

function Search-Todo {
    [alias("stodo")]
    param (
        [string] $search
    )
    Write-Host "Searching '$search' accross all files in $TODODirectory`:"
    findstr.exe /s /i /n $search $TODODirectory\*
}

function Move-Todo {
    [alias("mtodo")]
    param (
        [string] $scanDirectory = (Get-Location)
    )
    $todos = Get-ChildItem $scanDirectory -Filter 'todo*'
    foreach ($todo in $todos) {
        Move-Item -Path $todo.FullName -Destination $TODODirectory -ErrorAction Stop
    }
    Write-Host "All TODO files have been transferred to '$TODODirectory'."
}


# https://stackoverflow.com/a/7162842/29272030
$remindme =  {
    param([double] $minutesDelay, [string] $message, [string] $title)
    
    $delay = 60 * $minutesDelay
    Start-Sleep -Seconds $delay

    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        $message,
        $title,
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information
    ) | Out-Null
}

function Set-Reminder {
    [alias("remindme")]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [double] $Minutes,
        [Parameter(Position=1, Mandatory=$true, ValueFromRemainingArguments)]
        [string[]] $ReminderMessage
    )
    $msg = $ReminderMessage -join " "

    $job = Start-Job -ScriptBlock $remindme -ArgumentList $Minutes, $msg, "Reminder"
    $when = Get-TimeFromCity -City $CurrentCity -NoEcho -ErrorAction Stop
    $when = $when.AddMinutes($Minutes).ToString("HH:mm:ss")
    $jid = $job.Id
    Write-Host "Timer set -- reminder at $when (job id: $jid)"
}


# consider: 
# Start-Job -ScriptBlock {
#     Start-Sleep -Seconds 2
#     $ps = [powershell]::Create()
#     $ps.Runspace.ApartmentState = "STA"   # must be set before open
#     $ps.AddScript((Get-Content "$HOME\bar.ps1" -Raw)) | Out-Null
#     $rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
#     $rs.ApartmentState = "STA"
#     $rs.Open()
#     $ps.Runspace = $rs
#     $ps.Invoke()
#     $rs.Close()
# }
