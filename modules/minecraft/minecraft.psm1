Import-Module (Resolve-Path "$PSScriptRoot\..\..\configs\variables.psm1")

if (-not $MinecraftPath) {
    $MinecraftPath = [System.IO.Path]::Combine($env:APPDATA, ".minecraft")
}
if (-not (Test-Path $MinecraftPath)) {
    $err = "This module will not be loaded since no $MinecraftPath has been found.
            This is, Minecraft is not installed on this computer."
    Write-Error -ErrorAction Stop -Category NotImplemented -Message $err
}


function silentlyCreateDirectory {
    param (
        [string] $Path
    )
    
    if(-not (Test-Path -PathType Container -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -ErrorAction Stop |
        Out-Null
    }
}

$ModPath = [System.IO.Path]::Combine($MinecraftPath, "mods")
silentlyCreateDirectory $ModPath


function newMinecraftVersionModDirectory {
    param(
        [version] $Version
    )

    $minecraftVersionedModsPathContainer = [IO.Path]::Combine($MinecraftPath, "versioned-mods")
    silentlyCreateDirectory $minecraftVersionedModsPathContainer
    
    $versionedModPath = [IO.Path]::Combine($minecraftVersionedModsPathContainer, $Version)
    silentlyCreateDirectory $versionedModPath    
    return $versionedModPath
}


<#
.SYNOPSIS
    Switch Minecraft Mod versions.
.DESCRIPTION
    Mods from %APPDATA%\.minecraft\mods (.mc\mods) are moved to .minecraft\
    versioned-mods\$CurrentVersion (.mc\vmods\cver) and mods from .mc\vmods\
    $TargetVersion are moved to .mc\mods. If $CurrentVersion is not specified, 
    it is assumed that mods from $TargetVersion will be moved to .mc\mods 
    without flushing any mod. If TargetVersion is not specified, it is 
    effectively equivalent to "clean my mods carpet", this is: mods will 
    be moved to its .mc\vmods\cver directory but .mc\mods will not be populated
    from any other versioned mod.
.NOTES
    If no mods are found on the vmods\targetver, no error is rasied (i.e. no 
    mods were found to be moved: vacuity). This is effectively equivalent to 
    mcmodver -CurrentVersion cver
.NOTES
    No support for snapshot versions as of now.
.NOTES
    The alias mcmodver can be seen as "minecraft-mod-versioning".
.EXAMPLE
    Switch-MinecraftModVersion -CurrentVersion 1.21.11 -TargetVersion 1.16.1
    mcmodver 1.21.11 1.16.1
.EXAMPLE
    mcmodver 1.21.11
#>
function Switch-MinecraftModVersion {
    [alias("mcmodver")]
    param(
        [Parameter(Mandatory=$false)]
        [version] $CurrentVersion,
        [Parameter(Mandatory=$false)]
        [version] $TargetVersion = $null
    )

    if (-not $CurrentVersion -and -not $TargetVersion) {
        $m = "At least one [Current|Target]Version must be specified."
        Write-Error -ErrorAction Stop -Category InvalidArgument -Message $m
    }

    # ls .mc\mods -> .mc\vmods\cver
    if ($CurrentVersion) {
        $currVersionPath = newMinecraftVersionModDirectory $CurrentVersion
        Get-ChildItem $ModPath | ForEach-Object {
            Move-Item $_.FullName -Destination $currVersionPath -ErrorAction Stop
        }
        Write-Host "Mods from .minecraft\mods have been moved succesfully to $currVersionPath."
    }
    
    # ls .mc\vmods\tver -> .mc\mods
    if ($TargetVersion) {
        $tarVersionPath = newMinecraftVersionModDirectory $TargetVersion
        Get-ChildItem $tarVersionPath | ForEach-Object {
            Move-Item $_.FullName -Destination $ModPath -ErrorAction Stop
        }
        Write-Host "Mods from .minecraft\versioned-mods have been moved succesfully to $ModPath."
        Write-Host "You can now launch version $TargetVersion with the mods loaded."
    }

}


<#
.SYNOPSIS
    Move .jar file (or *jar files from a directory) to versioned mod path.
.DESCRIPTION
    Move a .jar file (i.e. a minecraft mod) to .minecraft\versioned-mods\
    <version>. If the specifed path is a directory instead, all *jar files in 
    the directory $Path will be moved to its versioned mod path. If no $Path is
    specified, then $Path defaults to $env:USERPROFILE\downloads.
.NOTES
    If the versioned mod path does not exist, it is silently created instead.
.NOTES
    The alias can be seen as "jars -> .mc\vmod\<v>".
.EXAMPLE
    Move-MinecraftModJars -Version 1.21.11 -Path .\here\random.jar
    jarstomcmodv 1.21.11 .\here\random.jar
    Moves specified .jar to .minecraft\versioned-mods\1.21.11\.
.EXAMPLE
    Move-MinecraftModJars -Version 1.21.11 -Path ".\tmp\"
    jarstomcmodv 1.21.11 tmp
    Moves all *jar files from ".\tmp\" to .mc\vmods\1.21.11.
.EXAMPLE
    jarstomcmodv 1.16.5
    Moves all *jar files from ~\downloads to .mc\vmods\1.16.5.
#>
function Move-MinecraftModJars {
    [alias("jarstomcmodv")]
    param(
        [version] $Version,
        [Parameter(Mandatory=$false)]
        [string] $Path = $null
    )
    
    $versionedPath = newMinecraftVersionModDirectory $Version

    if (-not $Path) {
        $resolvedPath = [IO.Path]::Combine($env:USERPROFILE, "downloads")
    } else {
        $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop
    }

    if (Test-Path -PathType Leaf -Path $resolvedPath) {
        if ((Get-Item $resolvedPath | Select-Object -ExpandProperty Extension) -eq '.jar') {
            Move-Item $resolvedPath -Destination $versionedPath
        }
        else {
            $err = "Argument '$resolvedPath' is not a valid Minecraft mod (aka .jar file)."
            Write-Error -ErrorAction Stop -Category InvalidArgument -Message $err
        }
    }
    
    # guaranteed to be a container because of Resolve-Path
    Get-ChildItem $resolvedPath -Filter '*jar' | ForEach-Object {
        Move-Item $_.FullName -Destination $versionedPath
    }
    Write-Host "Files matching *jar have been moved from $resolvedPath to $versionedPath."

}


function Open-FabricAPIInstaller {
    [alias("fabricapi")]
    param(

    )
    $fabricAPIPath =    Get-ChildItem -Path $MinecraftPath -Filter '*.jar' | 
                        Select-Object -First 1 -ExpandProperty FullName

    if ($fabricAPIPath) {
        Start-Process -FilePath $fabricAPIPath
    } else {
        Write-Error -Category ObjectNotFound -Message "No .jar file found in $MinecraftPath."
    }
}