<###############################################################################
## Get-RedditWallpapers.ps1
## .Contributors: Pandages, MrAusnadian, SpaceDeerEdith
## Version: 2.0
##
## .SYNOPSIS
## Downloads wallpaper images from a user-specified subreddit.
## 
## .DEPENDENCIES
## Background Intelligent Transfer Service (BITS)
## Reddit / JSON
###############################################################################>

[CmdletBinding()]
[Alias()]
[OutputType([int])]
param (
	[string]$wallpaperRoot = "C:\Wallpapers",
	[string]$subReddit = "EarthPorn",
	[int]$minWidth = 1920,
	[int]$minHeight = 1080
)


workflow Get-Wallpapers ($destination,$subReddit,$minWidth,$minHeight) {
	$images = Invoke-RestMethod https://www.reddit.com/r/$subReddit/hot/.json -Method Get -Body @{limit="100"}
	$current = 0
	$total = $images.data.dist
	Write-Output "Downloading images to $destination..."

    ForEach($child in $images.data.children) {
        $current++
        ## Aliases to make later uses easier to read ##
        $url = $child.data.url
        ## Sanitize Reddit Thread Title for use as a Filename ##
        $title = Remove-InvalidFileNameChars($child.data.title)


        if ($child.data.url -match "\.(jpe?)|(pn)g$") {

            if (($child.data.preview.images[0].source.height -lt $minHeight) -or ($child.data.preview.images[0].source.width -lt $minWidth )) {
                Write-Output "$title dimensions smaller than requested, skipped."
                } ## end if
            else{
                ## Create Filename from Reddit Thread Title, and File Extension from URL ##
                $fileName = $title + $url.Substring($url.LastIndexOf('.'))
                ## Create Counter for Download Progress Meter
		        $percent = $current / $total * 100
                ## Update Progress Meter
		        Write-Progress -Activity "Downloading images..." -Status "Downloading $fileName from $url..." -PercentComplete $percent
                $fullPath = Join-Path -Path $destination -ChildPath $fileName
		        if (Test-Path ($fullPath)) {
			        Write-Output " * Skipping $fileName - File already exists!"
		        } ## end if
		        else {
                    ## Download file using BITS ##
			        Start-BitsTransfer -Source $url -Destination $fullPath
                } ## end else
            } ## end else
            } ## end if
    } ## end foreach
} ## end workflow


<#
    .Synopsis
    Removes characters from a string which would make that string an Invalid filename or path.

    .Notes
    NAME: Remove-InvalidFileNameChars
    AUTHOR: Ansgar Wiechers https://stackoverflow.com/users/1630171/ansgar-wiechers
    
    .Link
    https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
#>
Function Remove-InvalidFileNameChars {
  param(
    [Parameter(Mandatory=$true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
    [String]$Name
  )

  $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
  $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
  return ($Name -replace $re)
}

## BEGIN SCRIPT EXECUTION ##

$destination = Join-Path -Path $wallpaperRoot -ChildPath $subReddit
if(-not (Test-Path $destination)) { New-Item -Path $destination -ItemType Directory | Out-Null }

try { 
    Get-Wallpapers $destination $subReddit $minWidth $minHeight
}
catch {
    Write-Error "An error occurred attempting to download images from $subReddit!"
}
finally {
    Write-Progress -Activity "Downloading images..." -Completed
}
