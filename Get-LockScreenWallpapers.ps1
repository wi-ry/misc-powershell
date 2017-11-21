$destination = "C:\Wallpapers\LockScreen"

workflow Get-Wallpapers ($destination) {
    $images = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets" | Where-Object {$_.length -gt 100000}
    ForEach ($image in $images) {
        Write-Output "Copying $($image.Name) to $destination..."
        Copy-Item $($image.FullName) "$destination\$($image.Name).jpg"
    }
}

function Remove-BadFiles ($files) {
    ForEach ($file in $files) {
        Add-Type -AssemblyName System.Drawing
        try {
			$img = [Drawing.Image]::FromFile($file)
		}
		catch {
			Write-Warning "An error occured processing $(Split-Path -Leaf $file)"
		}
        if ($img.Height -gt $img.Width) {
            $img.Dispose()
            Start-Sleep 1
            Remove-Item -Force $file
            $file = Split-Path -Leaf $file
            Write-Warning "$file is the wrong orientation to use as a wallpaper - Removing file..."
        }
        elseif (($img.Width -lt 1920) -OR ($img.Height -lt 1080)) {
            $img.Dispose()
            Start-Sleep 1
            Remove-Item -Force $file
            $file = Split-Path -Leaf $file
            Write-Warning "$file is smaller than 1920x1080 - Removing file..."
        }
        else {
            $img.Dispose()
        }
    }
}

if(-not (Test-Path $destination)) { New-Item -Path $destination -ItemType Directory | Out-Null }

try { 
    Get-Wallpapers $destination
}
catch {
    Write-Error "An error occurred attempting to copy images from the LockScreen cache!"
}
finally {
    $files = (Get-ChildItem $destination -Filter *.jpg).FullName
    Remove-BadFiles $files
}