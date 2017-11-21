$destination = ""
if ($destination -eq "") {
	$destination = Read-Host "Please specify a destination path"
	$script = (Join-Path $PSScriptRoot $MyInvocation.MyCommand.Name)	
	$file = Get-Content $script
	$file[0] = $file[0] -replace "destination = """"","destination = ""$destination"""
	$file | Set-Content $script -Force
}

if(-not (Test-Path $destination)) {
	New-Item -Path $destination -ItemType Directory | Out-Null
}

function Get-Wallpapers ($destination) {
	$copyList = @()
	$images = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets" | Where-Object {$_.length -gt 100000}
	foreach ($image in $images) {
		$fileBytes = $null
		$fileBytes = [System.IO.File]::ReadAllBytes($image.FullName)
		if (([System.BitConverter]::ToString($fileBytes[0]) + [System.BitConverter]::ToString($fileBytes[1])) -eq 'FFD8') {
			Add-Type -AssemblyName System.Drawing
			try {
				$img = [Drawing.Image]::FromFile($image.FullName)
			}
			catch {
				Write-Warning "An error occured processing $(Split-Path -Leaf $image)"
			}
			if (($img.Width -lt 1920) -OR ($img.Height -lt 1080) -OR ($img.Height -gt $img.Width)) {
				$img.Dispose()
			}
			else {
				$img.Dispose()
				$copyList += ($image.FullName)
			}
		}
	}
	foreach	($file in $copyList) {
		$fileName = Split-Path -Leaf $file
		Write-Output "Copying $fileName to $destination..."
		Copy-Item $file (Join-Path $destination "$fileName.jpg")
	}
}

try {
	Get-Wallpapers $destination
}
catch {
	Write-Error "An error occurred attempting to copy images from the LockScreen cache!"
}
