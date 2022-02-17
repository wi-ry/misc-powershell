[CmdletBinding()]
[Alias()]
[OutputType([int])]
param (
	[string]$wallpaperRoot = "C:\Wallpapers",
	[string]$subReddit = "EarthPorn",
	[int]$minWidth = 1920,
	[int]$minHeight = 1080
)

workflow Get-Wallpapers ($destination, $subReddit, $minWidth, $minHeight) {
	$images = Invoke-RestMethod https://www.reddit.com/r/$subReddit/new/.json -Method Get -Body @{limit="100"} | ForEach-Object { $_.data.children.data } | Where-Object { $_.preview.images.source.Width -ge $minWidth -AND $_.preview.images.source.Height -ge $minHeight } | Select -ExpandProperty url | Where-Object { $_ -match "\.(jpe?)|(pn)g$" }
	$current = 0
	$total = $images.count
	if ($total -eq 0) {
		Write-Warning "No images matching the min width '$minWidth' and min height '$minHeight' found in subreddit '$subReddit'"
	}
	else {
		Write-Output "Downloading $total images to $destination..."
		ForEach ($image in $images) {
			$fileName = $image.Substring($image.LastIndexOf("/") + 1)
			$current++
			$percent = $current / $total * 100
			Write-Progress -Activity "Downloading images..." -Status "Downloading $fileName from $image..." -PercentComplete $percent
			if (Test-Path (Join-Path -Path $destination -ChildPath $fileName)) {
				Write-Output " * Skipping $fileName - File already exists!"
			}
			else {
				Start-BitsTransfer -Source $image -Destination $destination
			}
		}
	}
}

$destination = Join-Path -Path $wallpaperRoot -ChildPath $subReddit
if(-not (Test-Path $destination)) { New-Item -Path $destination -ItemType Directory | Out-Null }

try { 
    Get-Wallpapers $destination $subReddit $minWidth $minHeight
}
catch {
    Write-Error "An error occurred attempting to download images from '$subReddit' subreddit!"
}
finally {
    Write-Progress -Activity "Downloading images..." -Completed
}
