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


<#
.SYNOPSIS
    Saves image copied to cliboard to a specified directory.
.DESCRIPTION
    Saves the last image copied from clipboard to a specified directory, with 
    the name directory_date_name.png.
.NOTES
    One can disable the directory_date_ prefix with -IgnorePrefix.
    The path the image is being saved to can be copied to clipboard directly 
    with the option -CopyPath.
    The alias "ss" comes from "save screenshot" (since it is the context under
    which I use this function the most). 
.EXAMPLE
    Save-CliboardImage -Directory foo -SuffixName bar -CopyPath
    Assume the date is 2026_05_26
    The image is saved to the path .\foo\
#>


function Save-ClipboardImage {
    [alias("ss")]
    param(
        [string] $Directory = (Get-Location).Path,
        [string] $SuffixName,
        [switch] $IgnorePrefix,
        [switch] $CopyPath
    )

    # non valid dir -> throw
    if (-not (Test-Path $Directory)) {
        Write-Error "Given directory does not exist: '$Directory'." -Category InvalidArgument
        return
    }
    # not suffix? mandatory
    if (-not $SuffixName) {
        $SuffixName = Read-Host "Enter the file name (do not provide extension)" 
    }

    # removePrefix -> ignore leaf and todaystr
    if (-not $IgnorePrefix) {
        $today = (Get-Date -Format "yyyy_MM_dd")
        $leaf = Split-Path $Directory -Leaf
        $fname = "$leaf`_$today`_$SuffixName"
    }
    # provided extension? throw
    if ($fname.Contains(".")) {
        Write-Error "Extension is not currently allowed." -Category InvalidArgument
        return
    }
    
    $fname = "$fname.png"
    $fpath = Join-Path -Path $dir -ChildPath $fname
    $img = getClipboardImg

    if (-not $img) {
        Write-Error -Category InvalidArgument -Message "The provided argument is not an image."
        return
    }

    $img.Save($fpath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Image saved to '$fpath'."

    if ($CopyPath) {
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

function Hide-Item {
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
    if ((Test-Path $fileName) -and ($removeExistent)) {
        Remove-Item $fileName
    }
    vim.exe $fileName

    # copy to clipboard
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
        [string] $EnvironmentalVariable,
        [string] $Value,
		[switch] $UI,
        [switch] $Verbose
    )
    
	if ($UI) {
	 	Write-Host "Launching sysdm.cpl to set environmental variable manually."
	    sysdm.cpl
        return
	}

    if ($EnvironmentalVariable.ToLower() -eq "path") {
        Write-Warning "Environmental variable %PATH% will not be set via PS."
        Write-Host "Instead, launching sysdm.cpl to set it manually."
	    sysdm.cpl
        return
    }

	$envPath = "Env:\$EnvironmentalVariable"

    New-Item -Path $envPath -Value $Value -ErrorAction Stop
    [System.Environment]::SetEnvironmentVariable($EnvironmentalVariable, $Value, "User")
    if ($Verbose) {
        Write-Host "Environmental variable $EnvironmentalVariable has been set to $value."
        Write-Host "You can now execute `$Env:$EnvironmentalVariable or open a command prompt and execute 'echo %$($variable.ToUpper())%'."
    }
}

# TODO: implement 
function Remove-EnvironmentalVariable {
    
}