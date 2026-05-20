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


