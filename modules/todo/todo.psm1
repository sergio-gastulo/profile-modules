Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\sensitive.psm1")

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
    return
}

function Move-Todo {
    [alias("mtodo")]
    param (
        [string] $scanDirectory = (Get-Location)
    )
    $todos = Get-ChildItem $scanDirectory -Filter 'todo*'
    foreach ($todo in $todos) {
        Move-Item -Path $todo.FullName -Destination $TODODirectory
    }
    Write-Host "All TODO files have been transferred to '$TODODirectory'."
    return
}

function Switch-Todo {
    [alias("todo")]
    param(
        [switch] $new,
        [string] $suffix,
        [switch] $search,
        [string] $query,
        [switch] $move,
        [string] $scanDir = (Get-Location)
    )

    if ($new) {
        New-Todo $suffix
        return
    }
    if ($search) {
        Search-Todo $query
        return
    }
    if ($move) {
        Move-Todo $scanDir
        return
    }
}


function reminder {
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
        [Parameter(Mandatory=$true)]
        [double] $minutes
    )

    if (-not $args) {
        Write-Error -Message "Missing message (`$args). Signature call: Set-Reminder -minutes MINUTES msg1 msg2 ..." -Category InvalidArgument
        return
    }
    $reminderMessage = $args -join " "
    $job = Start-Job -ScriptBlock {reminder $minutes $reminderMessage "Reminder"}
    $when = (Get-Date).AddSeconds($Seconds).ToString("HH:mm:ss")
    $jid = $job.Id
    Write-Host "Timer set -- reminder at $when (job id: $jid)"
}