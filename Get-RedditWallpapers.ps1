<###############################################################################
## Get-RedditWallpapers.ps1
## .Contributors: Pandages, MrAusnadian, SpaceDeerEdith
## Version: 3.1
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
    [string[]]$subReddits = @("EarthPorn", "Wallpapers", "spaceporn", "Art"),
    [int]$minWidth = 1920,
    [int]$minHeight = 1080,
    [ValidateSet("new", "top", "hot", "rising")]
    [String]$sort = "new",
    [bool]$ignorePortrait = $true
)

function Get-Wallpapers {
    param (
        [string]$destination,
        [string]$subReddit,
        [int]$minWidth,
        [int]$minHeight,
        [string]$sort,
        [bool]$ignorePortrait,
        [int]$start = 100
    )

    Start-Sleep 5
    $images = Invoke-RestMethod "https://www.reddit.com/r/$subReddit/$sort/.json?start=$start" -Method Get -Body @{ limit = "100" }
    $total = $images.data.dist
    Write-Output "Downloading images from /r/$subReddit sorted by $sort to $destination..."

    foreach ($child in $images.data.children) {
        $url = $child.data.url
        $title = Remove-InvalidFileNameChars $child.data.title
        [int]$height = $child.data.preview.images[0].source.height
        [int]$width = $child.data.preview.images[0].source.width

        if ($url -match "\.(jpe?)|(pn)g$" -and
            ($height -ge $minHeight) -and
            ($width -ge $minWidth) -and
            (-not ($ignorePortrait -and $child.data.preview.images[0].source.height -gt $child.data.preview.images[0].source.width))
        ) {
            $fileName = "$title$($url.Substring($url.LastIndexOf('.')))"
            $fullPath = Join-Path -Path $destination -ChildPath $fileName

            if (Test-Path $fullPath) {
                Write-Output " * Skipping $fileName - File already exists!"
            } else {
                $percent = ++$current / $total * 100
                Write-Progress -Activity "Downloading images..." -Status "Downloading $fileName from $url..." -PercentComplete $percent

                try {
                    Start-BitsTransfer -Source $url -Destination $fullPath
                } catch {
                    Write-Error "Failed to download $url"
                }
            }
        } else {
            Write-Output "$title skipped - Resolution ($width x $height) less than minimum resolution ($minWidth x $minHeight)"
        }
    }
}

Function Remove-InvalidFileNameChars {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Name
    )

    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    return $Name -replace $re
}

## BEGIN SCRIPT EXECUTION ##

foreach ($subReddit in $subReddits) {
    $destination = Join-Path -Path $wallpaperRoot -ChildPath $subReddit
    if (-not (Test-Path $destination)) { New-Item -Path $destination -ItemType Directory | Out-Null }

    try {
        Get-Wallpapers -destination $destination -subReddit $subReddit -minWidth $minWidth -minHeight $minHeight -sort $sort -ignorePortrait $ignorePortrait
        Get-Wallpapers -destination $destination -subReddit $subReddit -minWidth $minWidth -minHeight $minHeight -sort $sort -ignorePortrait $ignorePortrait -start 100
    } catch {
        Write-Error "An error occurred attempting to download images from /r/$subReddit!"
    } finally {
        Write-Progress -Activity "Downloading images..." -Completed
    }
}
