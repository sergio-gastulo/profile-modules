Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\sensitive.psm1")
Import-Module (Resolve-Path "$PSScriptRoot\..\time\time.psd1")


<#
.SYNOPSIS
    Create a new 'todo' file in $PWD.
.EXAMPLE
    New-Todo -Suffix foo
    Creates 'todo-foo' in $PWD and calls vim.exe on said file.
.EXAMPLE
    ntodo
    Creates 'todo-2026-05-31' in $PWD and calls vim.exe.
#>
function New-Todo {
    [alias("ntodo")]
    param(
        [string] $Suffix
    )
	if (-not $Suffix) {
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


<#
.SYNOPSIS
    Search a string accross all available TODOs file from $TODODirectory.
.EXAMPLE
    Search-Todo -Pattern museums
#>
function Search-Todo {
    [alias("stodo")]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Pattern
    )
    Write-Host "Searching '$Pattern' accross all files in $TODODirectory`:"
    findstr.exe /s /i /n $Pattern $TODODirectory\*
}


<#
.SYNOPSIS
    Move all TODO's available in $PWD to $TODODirectory.
.EXAMPLE
    Move-Todo -ScanDirectory ..\foo
    mtodo ..\foo
#>
function Move-Todo {
    [alias("mtodo")]
    param (
        [Parameter(Mandatory=$false)]
        [string] $ScanDirectory = (Get-Location)
    )
    $todos = Get-ChildItem $ScanDirectory -Filter 'todo*'
    foreach ($todo in $todos) {
        Move-Item -Path $todo.FullName -Destination $TODODirectory -ErrorAction Stop
    }
    Write-Host "All TODO files have been transferred to '$TODODirectory'."
}