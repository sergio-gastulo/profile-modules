

function Get-PowershellTheme {
    [alias("setPowTheme")]
    param (
        [string] $theme
    )

	$LocalPowershellSettings = [System.IO.Path]::Combine(
		${env:LOCALAPPDATA}, 
		"Packages", 
		"Microsoft.WindowsTerminal_8wekyb3d8bbwe",  # is this machine dependent?
		"LocalState", 
		"settings.json"
	)
    $json = Get-Content $LocalPowershellSettings | ConvertFrom-Json
    $json.profiles.list[0].colorScheme = $theme
    $json.profiles.list[1].colorScheme = $theme
    $json | ConvertTo-Json -depth 100 | Set-Content $LocalPowershellSettings
}

function Set-PowershellTheme {
    [alias("setPowTheme")]
    param (
        [string] $theme
    )

	$LocalPowershellSettings = [System.IO.Path]::Combine(
		${env:LOCALAPPDATA}, 
		"Packages", 
		"Microsoft.WindowsTerminal_8wekyb3d8bbwe",  # is this machine dependent?
		"LocalState", 
		"settings.json"
	)
    $json = Get-Content $LocalPowershellSettings | ConvertFrom-Json
    $json.profiles.list[0].colorScheme = $theme
    $json.profiles.list[1].colorScheme = $theme
    $json | ConvertTo-Json -depth 100 | Set-Content $LocalPowershellSettings
}


Export-ModuleMember Set-PowershellTheme, Get-PowershellTheme