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