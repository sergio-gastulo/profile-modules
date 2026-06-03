#region ========================== important  ==================================

# syntaxis: Open-Application
# aliases: "application" in lowercase or abbreviation (e.g app)

#endregion =====================================================================


function launchBinaryAndEcho {
	param(
		[string] $Binary,
		[string] $Arguments
	)

	if (-not (Test-Path $Binary)) {
		$e = "Path $Binary does not exist."
		Write-Error -Category InvalidArgument -ErrorAction Stop -Message $e
s	}

	if ($Arguments) {
		Write-Host "Launching $Binary with arguments '$Arguments'"
		Start-Process $Binary -ArgumentList $Arguments
	} else {
		Write-Host "Launching $Binary"
		Start-Process $Binary
	}
}


<#
.SYNOPSIS
	Open Zoom Application.
.DESCRIPTION
	Opens Zoom Application from binary directly.
.NOTES
	The full path binary is printed to stdout the check which path is being 
	launched.
.LINK
	Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
	Open-Zoom
.EXAMPLE
	zoom
#>
function Open-Zoom {
    [alias("zoom")]
    param(
	
	)	
	$zoom = [System.IO.Path]::Combine(${env:APPDATA}, "Zoom", "bin", "Zoom.exe")
    launchBinaryAndEcho $zoom
}


<#
.SYNOPSIS
	Opens Wolfram Application from the specified version.
.NOTES
	If no path is found, it is assumed that the version is wrong, but it won't 
	first test whether the Application is actually installed.
.NOTES
	The full path binary is printed to stdout the check which path is being launched.
.EXAMPLE
	Open-Wolfram -Version 14.3
.EXAMPLE
	wolfram 15.0
#>
function Open-Wolfram {
    [alias("wolfram")]
    param (
		[Parameter(Position=0, mandatory=$true)]
        [string]$Version
    )

	$binary = "WolframNB.exe"
	$binaryPath = [System.IO.Path]::Combine(
		$env:PROGRAMFILES,
		"Wolfram Research",
		"Wolfram",
		$Version,
		$binary
	)
	launchBinaryAndEcho $binaryPath
}

<#
.SYNOPSIS
	Opens Microsoft Office Applications from binaries.
.NOTES
	The full path binary is printed to stdout the check which path is being 
	launched.
.EXAMPLE
	Open-MicrosoftOffice -App Word
.EXAMPLE
	msof onote
#>
function Open-MicrosoftOffice {
	[alias("msof")]
    param(
		[string] $App
	)

	$Apps = @{
		"word" = "WINWORD.exe"
		"excel" = "EXCEL.exe"
		"point" = "POWERPNT.exe"
		"powerpoint" = "POWERPNT.exe"
		"onote" = "ONENOTE.exe"
		"onenote" = "ONENOTE.exe"
	}

	$App = $App.ToLower()
	$binary = $Apps[$App]
	if (-not $binary) {
		$err = "Argument '$App' is not a valid Microsoft Office Application."
		Write-Error -Category InvalidArgument -Message $err -ErrorAction Stop
	}

	$binaryPath = [System.IO.Path]::Combine(
		$env:ProgramFiles,
		"Microsoft Office",
		"root",
		"Office16",
		$binary
	)
	launchBinaryAndEcho $binaryPath
}


<#
.SYNOPSIS
	Opens Steam from binary.
.NOTES
	The full path binary is printed to stdout the check which path is being launched.
.EXAMPLE
	Open-Steam
.EXAMPLE
	steam
#>
function Open-Steam {
	[alias("steam")]
	param (
		
	)
	$steam = [System.IO.Path]::Combine(${env:ProgramFiles(x86)}, "Steam", "steam.exe")
	launchBinaryAndEcho $steam
}


<#
.SYNOPSIS
	Opens Spotify from command line.
.NOTES
	The full path binary is printed to stdout the check which path is being launched.
.EXAMPLE
	Open-Spotify
.EXAMPLE
	spotify
#>
function Open-Spotify {
	[alias("spotify")]
	param(

	)
	$spotify = [System.IO.Path]::Combine($env:APPDATA, "Spotify", "spotify.exe")
	launchBinaryAndEcho $spotify
}

<#
.SYNOPSIS
	Searches the query in google.com.
.DESCRIPTION
	Search the query provided by $args in google.com. By default, &utm=14 is
	provided to deactivate AI Summary. To disable this, use the flag -UseAll.
	The browser can also be specified via the argument -Browser. If you would 
	like to switch from a different search engine provided, specify -Engine.
.NOTES
	It is not guaranteed that switching the engine will provide better results.
	It hasn't been fully tested in other engines, probably some TODO.
.EXAMPLE
	Search-Google hello world
	Opens an Edge tab with the query "hello world" searched via google.com.
.EXAMPLE
	google powershell documentation
	Opens an Edge tab with the query "powershell documentation" searched via 
	google.com.
.EXAMPLE
	google -Browser chrome powershell tutorial
	Opens the URL query: https://powershell.com/search?q=help&udm=14 in the 
	Google Chrome browser.
.EXAMPLE
	google -UseAll how to disable google cookies
	Removes the "&udm=14" argument from the URL query.
#>
function Search-Google {
	[alias("google")]
	param (
		[Parameter(Position=0, ValueFromRemainingArguments)]
		[string[]] $Query,
		[switch] $UseAll,
		[string] $Browser = "msedge",
		[string] $Engine = "google"
	)

    if(-not $Query){
        Write-Error -Category InvalidArgument -Message "Arguments must be provided."
		return
    } else {
        $search = $Query -join "+"
    }

	$url = "https://$Engine.com/search?q=$search"
	if (-not $UseAll) {
		$url = "$url&udm=14"
	}
    Start-Process $Browser -ArgumentList $url
}


function Open-CounterStrike {
	[alias("cstrike")]
	param (
		
	)
	$binary = [System.IO.Path]::Combine(
		${env:ProgramFiles(x86)},
		"Counter-Strike 1.6",
		"hl.exe"
	)
	$arguments = "-nomaster -game cstrike"
	launchBinaryAndEcho $binary $arguments
}


function Open-YouTubeVideos {
	[alias("ytvids")]
	param (
		[Parameter(Position=0, ValueFromRemainingArguments)]
		[string[]] $Urls,
		[int] $Port = 8080,
		[string] $Browser = "msedge"
	)

	if (-not $Urls) {
		Write-Host "No `$Urls passed, getting `$Urls from clipboard."
		$Urls = Get-Clipboard
	}
	if (-not $Urls) {
		$err = "Did not get any data from Get-Clipboard. Aborting."
		Write-Error -Category InvalidArgument -ErrorAction Stop -Message $err	
	}
	Write-Host "Got `$Urls: '$Urls'."
	
	$executable =  [System.IO.Path]::Combine(
		$PSScriptRoot,
		"youtube",
		"src",
		"server.py"
	)
	$url = "http://localhost:$Port"
	Start-Process $Browser -ArgumentList $url
	python.exe $executable $Port $Urls
}


function Open-YouTube {
	[alias("yt")]
	param(
		[Parameter(Position=0, ValueFromRemainingArguments)]
		[string[]] $Query,
		[switch] $ShowPlaylists,
		[Parameter(Mandatory=$false)][string] $Browser = "msedge"
	)

	if ($ShowPlaylists) {
		$url = "https://www.youtube.com/feed/playlists"
   		Start-Process $Browser -ArgumentList $url
		return
	}
 
	$search = $Query -join "+"
	$url = "https://www.youtube.com/results?search_query=$search"
	Start-Process $Browser -ArgumentList $url

}