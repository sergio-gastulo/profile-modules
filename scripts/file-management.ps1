function Get-ClipboardImage {
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

    $img = Get-ClipboardImage
    $img.Save($fpath, [System.Drawing.Imaging.ImageFormat]::Png)   
    Write-Output "Image saved to '$fpath'."

    if (-not $forgetPath) {
        Set-Clipboard $fpath
        Write-Host "Path copied to Clipboard."
    }


}

Export-ModuleMember Save-ClipboardImage