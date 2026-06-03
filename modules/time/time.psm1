[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Target="CurrentCity")]
$CurrentCity = "Madrid"

$timezones = [ordered]@{
                    # UTC offset
    "chicago"		=	-5
    "lima"			= 	-5
    "ottawa"		= 	-4
    "madrid"		=	+2
    "bhubaneswar" 	= +5.5
    "tokyo"			= 	+9
}


function capitalize {
    param(
        [string] $str
    )
    $textInfo = (Get-Culture).TextInfo
    return $textInfo.ToTitleCase($str)
}

function showTime {
    foreach ($timezone in $timezones.GetEnumerator()) {
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
    Set time to Chicago TimeZone and also set it in PowerShell.
.EXAMPLE
    time -Show
    Show current time in various cities and timezones ($timezones).
.EXAMPLE
    Get-TimeFromCity -City Lima -NoEcho -TimeFormat "HH:mm:ss"
    Sets prompt time to Lima's TimeZone silently.
#>
function Get-TimeFromCity {
    [alias("time")]
	param(
		[string] $City,
        [string] $TimeFormat,
        [switch] $NoEcho,
        [switch] $Show	
    )

    if ($Show) {
        showTime
        return
    }

    $city = $city.ToLower()
    if (-not $timezones.Contains($city)) {
        Write-Error -Message "City '$city' is not in hashable keys." -Category InvalidArgument
        return
    }

    $offset = $timezones[$city]
    $time = (Get-Date).ToUniversalTime().AddHours($offset)
    $capitalized = capitalize $city
    $script:CurrentCity = $capitalized
    if (-not $NoEcho) {
        Write-Host "Current time in $capitalized`: $time"
        return
    }

    # if format is specified, then is returned as a string in said format
    if ($TimeFormat) {
        $asfmt = $time.ToString($TimeFormat)
        return $asfmt
    }
    # otherwise, return as date expresssion
    return $time 
}

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

Export-ModuleMember -Variable CurrentCity -Function * -Alias *