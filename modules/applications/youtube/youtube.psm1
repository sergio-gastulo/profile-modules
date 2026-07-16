$ProjectModule = Resolve-Path "$PSScriptRoot\..\..\..\"
Import-Module "$ProjectModule\configs\variables.psm1"

if (-not (Test-Path $VenvPythonExecutable)) {
    $err = "No virtual environmental python executable found: '$VenvPythonExecutable'."
    Write-Error -Category NotImplemented -ErrorAction Stop -Message $err
}


<#
.SYNOPSIS
    Invoke YouTube HTTP Server to serve a single or an array of videos.
.DESCRIPTION
    The single video has to be parsable as per urlparse.py. An array of videos
    can be specified by playlist name or by passing a list of YouTube urls.
.NOTES
    This function is a single wrapper of the source code which can be read at 
    youtube/src.
.NOTES
    Playlist takes precedence over YouTubeURL whenever both are specified.
.EXAMPLE
    ytserver -PlaylistName myplaylist
.EXAMPLE
    ytserver -YouTubeURL https://www.youtube.com/watch?v=l1W82fIRnp4
.EXAMPLE
    ytserver -YouTubeURL https://www.youtube.com/watch?v=atxYe-nOa9w&list=PLurt6-3Wzoh-KZW6ETZRz8XD7p9YAcAvO, `
                         https://www.youtube.com/watch?v=oP32vo2Pu8c
#>
function Invoke-YouTubeHTTPServer {
    [alias("ytserver")]
    param (
        [string[]] $YouTubeURL,
        [string] $PlaylistName,
        [int] $Port = 8080,
        [string] $Domain = "localhost"
    )

    $mainPath = "$PSScriptRoot\main.py"
    $executableArgs = [Collections.Generic.List[string]]::new()
    $executableArgs.Add("--port=$Port")
    $executableArgs.Add("--domain=$Domain")

    if ($PlaylistName) {
        $executableArgs.Add("--playlist=$PlaylistName")
        & $VenvPythonExecutable $mainPath $executableArgs
        return
    }

    if (-not $YouTubeURL) {
        $e = "Neither YouTubeURL[s] nor PlaylistName provided, aborting."
        Write-Error -ErrorAction Stop -Category InvalidArgument -Message $e
    }

    $urlString = "--urls=[" + (($YouTubeURL | ForEach-Object {"'$_'"}) -join ', ') + "]"
    $executableArgs.Add($urlString)
    & $VenvPythonExecutable $mainPath $executableArgs

}


<#
.SYNOPSIS
	Search or open a YouTube query in the specified browser.
.NOTES
	Relies on a simple saps 'url'.
.EXAMPLE
	Open-YouTube -ShowPlaylists
	Opens "https://www.youtube.com/feed/playlists on browser."
.EXAMPLE
	yt manim 3blue1brown
	Opens "https://www.youtube.com/results?search_query=manim+3blue1brown on 
	browser."
#>
function Open-YouTube {
	[alias("yt")]
	param(
		[Parameter(Position=0, ValueFromRemainingArguments)]
		[string[]] $Query,
		[switch] $ShowPlaylists,
		[switch] $WatchLater,
		[switch] $History,
		[switch] $LikedVideos,
		[Parameter(Mandatory=$false)][string] $Browser = "msedge"
	)

	if ($ShowPlaylists) {
		$url = "https://www.youtube.com/feed/playlists"
   		Start-Process $Browser -ArgumentList $url
		return
	}
	
	if ($WatchLater) {
		$url = "https://www.youtube.com/playlist?list=WL"
		Start-Process $Browser -ArgumentList $url
		return
	}
	
	if ($History) {
		$url = "https://www.youtube.com/feed/history"
		Start-Process $Browser -ArgumentList $url
		return
	}
	
	if ($LikedVideos) {
		$url = "https://www.youtube.com/playlist?list=LL"
		Start-Process $Browser -ArgumentList $url
		return
	}

	$search = $Query -join "+"
	$url = "https://www.youtube.com/results?search_query=$search"
	Start-Process $Browser -ArgumentList $url

}