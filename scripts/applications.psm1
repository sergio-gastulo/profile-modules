# syntaxis: Open-Application
# alias: application (lowercase)

function Open-Zoom {
    [alias("zoom")]
    param(
	
	)	
	$zoom = [System.IO.Path]::Combine(${env:APPDATA}, "Zoom", "bin", "Zoom.exe")
    Write-Host "Launching $zoom."
	Start-Process $zoom
}

function Open-Wolfram {
    [alias("wolfram")]
    param (
		[Parameter(Position=0, mandatory=$true)]
        [string]$version
    )

	$binary = "WolframNB.exe"
	$binaryPath = [System.IO.Path]::Combine(
		$env:PROGRAMFILES,
		"Wolfram",
		$version,
		$binary
	)
	if (-not (Test-Path $binaryPath)) {
		Write-Error -Message "Binary does not exist. Wrong version: $version" -Category InvalidArgument
		return
	}
	Write-Host "Launching: $path."
	Start-Process $path
}


function Open-MicrosoftOffice {
	[alias("msof")]
    param(
		[string] $app
	)

	$apps = @{
		"word" = "WINWORD.exe"
		"excel" = "EXCEL.exe"
		"point" = "POWERPNT.exe"
		"powerpoint" = "POWERPNT.exe"
		"onote" = "ONOTE.exe"
		"onenote" = "ONOTE.exe"
	}

	$app = $app.ToLower()
	if (-not $apps.Contains($app)) {
		Write-Error -Category InvalidArgument -Message "Argument '$app' is not a valid Microsoft Office Application."
		return
	}

	$officePath = [System.IO.Path]::Combine(
		$env:PROGRAMFILES,
		"Microsoft Office",
		"root",
		"Office16",
		$apps[$app]
	)
	Start-Process $officePath
}


function Open-Steam {
	[alias("steam")]
	param (
		
	)
	$steam = [System.IO.Path]::Combine(${env:ProgramFiles(x86)}, "Steam", "steam.exe")
	Write-Host "Launching steam from $steam"
	Start-Process $steam	
}

function Open-Spotify {
	[alias("spotify")]
	param(

	)
	$spotify = [System.IO.Path]::Combine($env:APPDATA, "Spotify", "spotify.exe")
	Write-Host "Launching spotify from $spotify"
	Start-Process $spotify
}


function Search-Google {
	[alias("google")]
	param (
		[switch] $useAll,
		[string] $browser = "msedge",
		[string] $engine = "google"
	)

    if(-not $args){
        Write-Error -Category InvalidArgument -Message "Arguments must be provided."
		return
    } else {
        $search = $args -join "+"
    }

	$url = "https://$engine.com/search?q=$search"
	if (-not $useAll) {
		$url = "$url&udm=14"
	}
    Start-Process $browser -ArgumentList $url
}

# Export-ModuleMember -Function * -Alias *