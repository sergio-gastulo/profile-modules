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
    The image is saved to the path .\foo\foo_2026_05_26_bar.png
    And the full path is saved to Clipboard.
.EXAMPLE
    ss -SuffixName here -IgnorePrefix
    Image is saved to $PWD with name here.png.
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
    $Directory = Resolve-Path $Directory
    $fpath = Join-Path -Path $Directory -ChildPath $fname
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


function resolveExecutable {
    param(
        [string] $exe
    )
    $fullExePath = Get-Command $exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    return $fullExePath
}


<#
.SYNOPSIS
    Copies full resolved path to Clipboard.
.NOTES
    Useful for attaching documents: a simple Ctrl+V in the explorer window and 
    the document is ready to be sent.
.EXAMPLE
    Copy-Path .
    Copies $PWD to Clipboard.
.EXAMPLE 
    cpa .\foo\bar\baz.ps1
    Copies $PWD\foo\bar\baz.ps1 to clipboard.
#>
function Copy-Path {
    [alias("cpa")]
    param(
        [string] $Path
    )

    if (-not (Test-Path $Path)) {
        # check if executable
        $fullexe = resolveExecutable $Path
        if (-not $fullexe) {
            # no exe found
            Write-Error -Category InvalidArgument -Message "Path '$Path' does not exist."
            return
        }
        $resolved = $fullexe
    } else {
        $resolved = Resolve-Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path
    }
    Write-Host "Resolved: '$resolved'."
    $resolved | Set-Clipboard 
} 


<#
.SYNOPSIS
    Open a privileged PowerShell session and executing command if provided.
.DESCRIPTION
    Opens a privileged PowerShell session in $PWD and executes any provided 
    command.
.NOTES
    Execute at your own risk.
.EXAMPLE
    Start-PowerShellAdminMode
    Opens a simple privileged PowerShell session in $PWD.
.EXAMPLE
    sudo echo 1+1
    Opens a simple privileged PowerShell session in $PWD, and echoes '1+1' in 
    the elevated terminal.
#>
function Start-PowerShellAdminMode{
    [alias("sudo")]
    param(
        [Parameter(Mandatory=$false, ValueFromRemainingArguments)]
        [string] $Action
	)
    $currentDir = Get-Location
    $run = "Set-Location $currentDir; $Action"
    $command = "-NoProfile -NoExit -Command $run"
    Write-Host "Launching PowerShell in Administration Mode with the following commands: '$command'."
    Start-Process PowerShell -Verb RunAs -ArgumentList $command
}

<#
.SYNOPSIS
    Hide an item from Get-ChildItem (ls) unless -Force is called.
.EXAMPLE
    Hite-Item file.txt
#>
function Hide-Item {
    [alias("hide")]
	param(
		[string] $Path
	)

    if (-not (Test-Path $Path)) {
        Write-Error "Invalid Path: '$Path'." -Category InvalidArgument 
        return
    }
    
    $item = Get-Item $Path -ErrorAction Stop
    $item.Attributes = $item.Attributes -bor "Hidden"
	Write-Host "File hidden: $Path"
}


<#
.SYNOPSIS
    Set-Location, but if path does not exist it's created.
.DESCRIPTION
    Set-Location. If path does not exist, it creates the file or directory 
    (depending on what has been specified). Then, 'cd's to the aforementioned 
    directory (or the directory of the file, depending on the case.)
.NOTES
    Does not raise any File-DoesNotExist error, instead prompts for action.
.EXAMPLE
    mcd non\existent\path
#>
function Set-LocationModified {
    [alias("mcd")]
	param(
		[Parameter(Position=0, mandatory=$true)]
		[string] $Path
	)

	# if file/dir doesn't exist, create it
	if(-not (Test-Path $Path)){	
		Write-Host "'$Path' is not a valid path."
		Write-Host @"
	Select any of the following options:
		{
			d: create directory '$Path'
			f: create file '$Path'
			q: quit
		}
"@
		$opt = Read-Host "[d/f/[q]]"
		switch ($opt) {
			'd' {New-Item $Path -ItemType "Directory"}
			'f' {New-Item $Path -ItemType "File"}
			default {
				Write-Host "Bye."
				return
			}
		}	
	}
	
	if (Test-Path $Path -PathType Leaf) {
		Set-Location (Split-Path $Path)
	} elseif (Test-Path $Path -PathType Container) {
		Set-Location ($Path)
	} else {
		Write-Error -Category Unkown -Message "Unkown error. Path='$Path'."
		return
	}	
}


<#
.SYNOPSIS
    Create a plain text file and edit it directly with vim.
.NOTES
    The name of the path defaults to 't' (no extension).
.EXAMPLE
    New-TemporaryVimFileEdit
    Runs vim.exe t.
.EXAMPLE
    vimt -RemoveExistent -FileName here
    Removes any file with name 'here' (includes directory) in $PWD. Then, 
    executes 'vim.exe here'.
.EXAMPLE
    vimt -SetClipboard
    Useful when writing emails. After ':q'uitting vim, the content is copied to
    Clipboard automatically.
#>
function New-TemporaryVimFileEdit {
    [alias("vimt")]
	param(
		[switch] $RemoveExistent,
        [switch] $SetClipboard,
		[string] $FileName = "t"
	)

    # create / remove file
    if ((Test-Path $FileName) -and ($RemoveExistent)) {
        Remove-Item $FileName
    }
    vim.exe $FileName

    # copy to clipboard
    if ($SetClipboard) {
        Get-Content $FileName -Encoding UTF8 | Set-Clipboard
        Write-Host "Content set to clipboard."
    }
}


<#
.SYNOPSIS
    Set a *new* environmental variable for any process (including the current 
    PowerShell process).
.NOTES
    Editting %PATH% is *NOT* allowed for security reasons. Didn't even bother to
    implement this. If %PATH% is provided as env-var name, the UI is launched 
    and a warning is printed.
.NOTES
    If the environmental variable already exists, a error is raised (because of 
    New-Item).
.EXAMPLE
    Set-EnvironmentalVariable -EnvironmentalVariable foo -Value bar
    Sets $env:foo = 'bar'.
.EXAMPLE
    setenv -UI
    The UI is launched: sysdm.cpl
.EXAMPLE
    setenv foo bar -NoEcho
    Unnecessary printing statements are removed.
#>
function Set-EnvironmentalVariable {
    [alias("setenv")]
    param (
        [string] $EnvironmentalVariable,
        [string] $Value,
		[switch] $UI,
        [switch] $NoEcho
    )
    
	if ($UI) {
	 	Write-Host "Launching sysdm.cpl to set environmental variable manually."
	    Start-Process sysdm.cpl
        return
	}

    if ($EnvironmentalVariable.ToLower() -eq "path") {
        Write-Warning "Environmental variable %PATH% will not be set via PS."
        Write-Host "Instead, launching sysdm.cpl to set it manually."
	    Start-Process sysdm.cpl
        return
    }

	$envPath = "Env:\$EnvironmentalVariable"

    # set for current PowerShell process
    New-Item -Path $envPath -Value $Value -ErrorAction Stop
    # set for future processes
    [System.Environment]::SetEnvironmentVariable($EnvironmentalVariable, $Value, "User")
    if (-not $NoEcho) {
        Write-Host "Environmental variable $EnvironmentalVariable has been set to $value."
        Write-Host "You can now execute `$Env:$EnvironmentalVariable or open a command prompt and execute 'echo %$($EnvironmentalVariable.ToUpper())%'."
    }
}


<#
.SYNOPSIS
    Remove an already existing environmental variable from any process (
    including the current PowerShell session).
.NOTES
    As in Set-EnvironmentalVariable, %PATH% is forbidden. The UI is launched 
    instead.
.EXAMPLE
    Remove-EnvironmentalVariable -EnvironmentalVariable foo
    Removes $env:foo.
#>
function Remove-EnvironmentalVariable {
    [alias("delenv")]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string] $EnvironmentalVariable
    )

    if ($EnvironmentalVariable.ToLower() -eq "path") {
        Write-Warning "Removing %PATH% is FORBIDDEN."
        Write-Host "Instead, launching sysdm.cpl to set/delete/append any necessary path."
	    Start-Process sysdm.cpl
        return
    }

    $envpath = "Env:\$EnvironmentalVariable"
    $value = (Get-Item $envpath).Value
    $sure = Read-Host "Remove variable '$EnvironmentalVariable' with value '$value'? [Y] Yes  [N] No  (default is N): "

    if (-not ($sure.ToLower() -in @('y', 'yes'))) {
        Write-Host "Aborted."
        return
    }

    # https://stackoverflow.com/a/69968124/29272030
    # remove from current PowerShell process
    Remove-Item -Path $envpath -ErrorAction Stop
    # remove for future processes
    [System.Environment]::SetEnvironmentVariable($EnvironmentalVariable, '', "User")

    Write-Host "Variable '$EnvironmentalVariable' has been removed from all processes."

}