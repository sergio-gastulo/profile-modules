<#
.SYNOPSIS
    Create a VSCode region to group code within the same file.
.NOTES
    It pastes to clipboard by default. You can turn it off with -Echo.
.EXAMPLE
    ./scripts/region.ps1 important
    Will set to your clipboard the following string:
        #region ========================== important  ==================================
        #endregion =====================================================================
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $Title,
    [switch] $Echo

)

$title_length       =   $Title.Length
if ($title_length % 2 -eq 1) {
    $Title          +=  " "
    $title_length   +=  1
}

$editor_length      =   80
$half               =   $editor_length / 2
$padding            =   1
$region_decorator   =   "="
$begin_region       =   "#region "
$end_region         =   "#endregion "
$begin_n            =   $begin_region.Length


$gen    = $title_length / 2
$left_pad = $half - ($padding + $gen + $begin_n)
$right_pad = $half - ($padding + $gen)

# https://www.reddit.com/r/PowerShell/comments/7a39p9/comment/dp6r93m
$region_text = New-Object System.Text.StringBuilder

# top_line
[void]$region_text.Append($begin_region)
[void]$region_text.Append($region_decorator * ($left_pad))
[void]$region_text.Append(" " * $padding  + $Title + " " * $padding)
[void]$region_text.Append($region_decorator * $right_pad)

# bottom_line
[void]$region_text.Append("`n")
[void]$region_text.Append($end_region)
[void]$region_text.Append($region_decorator * ($editor_length - $end_region.Length))

$str = $region_text.ToString() 
if ($Echo) {
    Write-Host $str
} else {
    $str | Set-Clipboard 
}
