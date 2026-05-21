function getClipboardImg {
    Add-Type -AssemblyName System.Windows.Forms
    if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
        $img = [System.Windows.Forms.Clipboard]::GetImage()
        return $img
    }
    else {
        Write-Error -Message "No image found in clipboard." -Category InvalidArgument
        return
    }
}


function Save-ClipboardImage {
    [alias("ss")]
    param(
        [string] $fname,
        [string] $dir = (Get-Location).Path,
        [switch] $removePrefix,
        [switch] $forgetPath
    )

    # validate arguments
    if (-not (Test-Path $dir)) {
        Write-Error "Given directory does not exist: '$dir'." -Category InvalidArgument
        return
    }
    if (-not $fname) {
        $fname = Read-Host "Enter the file name (do not provide extension)" 
    }

    if (-not $removePrefix) {
        $today = (Get-Date -Format "MM_dd_yyyy")
        $leaf = Split-Path $dir -Leaf
        $fname = "$leaf`_$today`_$fname"
    }
    $fpath = Join-Path -Path $dir -ChildPath $fname
    if ($fname.extension) {
        Write-Error "Extension is not currently allowed." -Category InvalidArgument
        return
    }

    $img = getClipboardImg
    $img.Save($fpath, [System.Drawing.Imaging.ImageFormat]::Png)   
    Write-Output "Image saved to '$fpath'."

    if (-not $forgetPath) {
        Set-Clipboard $fpath
        Write-Host "Path copied to Clipboard."
    }


}

function Copy-Path {
    [alias("cpa")]
    param(
        [string] $path
    )

    if (-not (Test-Path $path)) {
        Write-Error -Category InvalidArgument -Message "Path '$path' does not exist."
        return
    }
    Resolve-Path $path | Select-Object -ExpandProperty Path | Set-Clipboard 
} 


function Start-PowershellAdminMode{
    [alias("sudo")]
    param(

	)
    $currentDir = Get-Location | Select-Object -ExpandProperty Path
    $run = "-Command Set-Location $currentDir; $args"
    $command = "-NoProfile -NoExit $run"
    Start-Process powershell -Verb RunAs -ArgumentList $command
}

function Set-HideItem {
    [alias("hide")]
	param(
		[string] $path
	)

    if (-not (Test-Path $path)) {
        Write-Error "Invalid Path: '$path'." -Category InvalidArgument 
        return
    }
    
    $item = Get-Item $path -ErrorAction Stop
    $item.Attributes = $item.Attributes -bor "Hidden"
	Write-Host "File hidden: $path"
}

function Set-LocationModified {
    [alias("mcd")]
	param(
		[Parameter(Position=0, mandatory=$true)]
		[string] $path
	)

	# if file/dir doesn't exist, create it
	if(-not (Test-Path $path)){	
		Write-Host "'$path' is not a valid path."
		Write-Host @"
	Select any of the following options:
		{
			d: create directory '$path'
			f: create file '$path'
			q: quit
		}
"@
		$opt = Read-Host "[d/f/[q]]"
		switch ($opt) {
			'd' {New-Item $path -ItemType "Directory"}
			'f' {New-Item $path -ItemType "File"}
			default {
				Write-Host "Bye."
				return
			}
		}	
	}
	
	if (Test-Path $path -PathType Leaf) {
		Set-Location (Split-Path $path)
	} elseif (Test-Path $path -PathType Container) {
		Set-Location ($path)
	} else {
		Write-Error -Category InvalidArgument -Message "Unkown error. Path='$path'."
		return
	}	
}


function New-TemporaryVimFileEdit {
    [alias("vimt")]
	param(
		[switch] $removeExistent,
        [switch] $setClipboard,
		[string] $fileName = "t"
	)

    # create-remove file
    if (Test-Path $fileName) {
        if ($removeExistent) {
            Remove-Item $fileName
        }
        vim.exe $fileName
    }

    # set clipboard
    if ($setClipboard) {
        Get-Content $fileName -Encoding UTF8 | Set-Clipboard
        Write-Host "Content set to clipboard."
    }
}

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
        Write-Host "Instead, launching sysdm.cpl to set it manually."
	    sysdm.cpl
        return
    }

    New-Item -Path "$Env`:$variable" -Value $value
    [System.Environment]::SetEnvironmentVariable($variable, $value, "User")
    Write-Host "Environmental variable $variable has been set to $value."
    Write-Host "You can now execute `$Env:$variable or open a command prompt and execute 'echo %$($variable.ToUpper())%'."

}


Export-ModuleMember @(
    "Save-ClipboardImage",
    "Copy-Path",
    "Start-PowershellAdminMode",
    "Set-HideItem",
    "Set-LocationModified",
    "New-TemporaryVimFileEdit",
    "Set-EnvironmentalVariable"
) -Alias @(
    "ss",
    "cpa",
    "sudo",
    "hide",
    "mcd",
    "vimt",
    "setenv"
)