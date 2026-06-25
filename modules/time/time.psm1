[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Target="CurrentCity")]
$CurrentCity = "Madrid"

$TimeZones = [ordered]@{
                    # UTC offset
    "chicago"		=	-5
    "lima"			= 	-5
    "ottawa"		= 	-4
    "madrid"		=	+2
    "bhubaneswar" 	= +5.5
    "tokyo"			= 	+9
}

$textInfo = (Get-Culture).TextInfo
function capitalize {
    param(
        [string] $str
    )
    return $textInfo.ToTitleCase($str)
}


function showTime {
    foreach ($timezone in $TimeZones.GetEnumerator()) {
        $utcTime = (Get-Date).ToUniversalTime()
        $formated = $utcTime.AddHours($timezone.Value).ToShortTimeString()
        $city = capitalize ($timezone.Name)
        Write-Host "Current time in $city`: $formated"
    }
}


<#
.SYNOPSIS
    Show / Set time information to prompt or print to stdout.
.EXAMPLE
    Get-TimeFromCity -City Chicago
    Set time to Chicago and print to stdout Chicago's DateTime.
.EXAMPLE
    time -Show
    Show current time in various cities and timezones ($TimeZones).
.EXAMPLE
    time -City Lima -DontEcho
    Sets prompt time to Lima's TimeZone silently.
.EXAMPLE
    time -City Lima -DontSet
    Print to stdout current Lima's time without setting it to prompt.
.EXAMPLE
    time -City Lima -DontSet -DontEcho
    Returns time in [System.DateTime] type.
#>
function Get-TimeFromCity {
    [alias("time")]
    param(
        [switch] $Show,
        [string] $City,
        [string] $TimeFormat,
        [switch] $DontEcho,
        [switch] $DontSet
    )

    if ($Show) {
        showTime
        return
    }

    $lcity = $City.ToLower()
    if (-not $TimeZones.Contains($lcity)) {
        $err = "City '$lcity' is not in `$TimeZones dictionary."
        Write-Error -Category InvalidArgument -Message $err
        return
    }
    $offset = $TimeZones[$lcity]
    $time = (Get-Date).ToUniversalTime().AddHours($offset)
    $capitalized = capitalize $lcity
    
    if (-not $DontSet) { # if set
        $script:CurrentCity = $capitalized
    }
    if (-not $DontEcho) { # if echo
        Write-Host "Current time in $capitalized`: $time"
        return
    }
    if ($TimeFormat) {
        $time = $time.ToString($TimeFormat)
    }
    return $time
}


<#
.SYNOPSIS
    Print Today's date.
.EXAMPLE
    Get-Today
    today
#>
function Get-Today {
    [alias("today")]
	param(
		
	)
	$day = get-date -UFormat "%A"
	$capitalized = capitalize $day
    $res = get-date -UFormat "%d de %B del %Y"
	$res = "$capitalized $res."
	Write-Host $res
}


# -------------- DO NOT DELETE: -------------- 
# https://stackoverflow.com/a/38355944/29272030
Export-ModuleMember -Variable CurrentCity -Function * -Alias *
# -------------- DO NOT DELETE: -------------- 