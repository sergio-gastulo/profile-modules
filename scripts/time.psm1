[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Target="CurrentCity")]
$CurrentCity = "Madrid"

$timezones = [ordered]@{
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

function Show-Time {
    param(

    )
    foreach ($timezone in $timezones.GetEnumerator()) {
        $utcTime = (Get-Date).ToUniversalTime()
        $formated = $utcTime.AddHours($timezone.Value).ToShortTimeString()
        $city = capitalize ($timezone.Name)
        Write-Host "Current time in $city`: $formated"
    }
}

function Get-TimeFromCity {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Target="CurrentCity")]
	param(
		[string] $city,
        [switch] $echo
	)
    $city = $city.ToLower()
    if (-not $timezones.Contains($city)) {
        Write-Error -Message "City '$city' is not in hashable keys." -Category InvalidArgument
        return
    }

    $timefmt = "HH:mm:ss"
    $offset = $timezones[$city]
    $time = (Get-Date).ToUniversalTime().AddHours($offset).ToString($timefmt)
    $capitalized = capitalize $city
    $CurrentCity = $capitalized
    if ($echo) {
        Write-Host "Current time in $capitalized`: $time"
    }
    return $time 
}

function Get-Today {
	param(
		
	)
	$day = get-date -UFormat "%A"
	$capitalized = capitalize $day
    $res = get-date -UFormat "%d de %B del %Y"
	$res = "$capitalized $res."
	Write-Host $res
}


Export-ModuleMember -Function @(
    "Get-TimeFromCity",
    "Show-Time",
    "Get-Today"
) -Alias @(
    "time",
    "showtime",
    "today"
)
Export-ModuleMember -Variable "CurrentCity"
