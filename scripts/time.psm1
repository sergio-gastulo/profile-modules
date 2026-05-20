function capitalize {
    param(
        [string] $str
    )
    $textInfo = (Get-Culture).TextInfo
    return $textInfo.ToTitleCase($str)
}


function Get-Time {
	[alias("time")]
	param(
		[string] $city,
        [switch] $list,
        [bool] $echo = $true
	)

	# time zones in UTC
	$timezones = [ordered]@{
		"chicago"		=	-5
		"lima"			= 	-5
		"ottawa"		= 	-4
		"madrid"		=	+2
		"bhubaneswar" 	= +5.5
		"tokyo"			= 	+9
	}
	
    if ($list) {
        foreach ($timezone in $timezones.GetEnumerator()) {
            $utcTime = (Get-Date).ToUniversalTime()
            $formated = $utcTime.AddHours($timezone.Value).ToShortTimeString()
            $city = capitalize ($timezone.Name)
            Write-Host "Current time in $city`: $formated"
        }
        return
    }

    if (-not $timezones.Contains($city)) {
        Write-Error -Message "City '$city' is not in hashable keys." -Category InvalidArgument
        return
    }

	if ($city.ToLower() -in $timezones.keys) {
        $timefmt = "HH:mm:ss"
		$offset = $timezones[$city]
        $time = (Get-Date).ToUniversalTime().AddHours($offset).ToString($timefmt)
        $Global:city = $city
        if ($echo) {
            $capitalized = capitalize $city
            Write-Host "Current time in $capitalized`: $time"
            return 
        }
		return $time 
	}

}


Export-ModuleMember Get-Time
