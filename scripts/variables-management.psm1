# the idea is to have the same syntax as in setx but %PATH% will never be 
# edited via command line -- too dangerous.
# might change my mind later tho
function Set-EnvironmentalVariable {
    [alias("setenv")]
    param (
        [string] $variable,
        [string] $value
    )
    
    if ($variable.ToLower() -eq "path") {
        Write-Warning "Environmental variable %PATH% will not be set via PS."
        Write-Host "Instead, Launching sysdm.cpl" -ForegroundColor Blue
	    sysdm.cpl
        return
    }

    New-Item -Path "$Env`:$variable" -Value $value
    [System.Environment]::SetEnvironmentVariable($variable, $value, "User")
    Write-Host "Environmental variable $variable has been set to $value."
    Write-Host "You can now execute `$Env:$variable or open a command prompt and execute 'echo %$($variable.ToUpper())%'."

}