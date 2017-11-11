$destination = "C:\Wallpapers\"

workflow Get-Wallpapers ($destination) {
    $images = Invoke-RestMethod https://www.reddit.com/r/earthporn/new/.json -Method Get -Body @{limit="100"} | ForEach-Object { $_.data.children.data.url } | ? { $_ -match "\.jpg$" }
    ForEach -Parallel ($image in $images) {
        Write-Output "Downloading $image..."
        Start-BitsTransfer -Source $image -Destination $destination
    }
}
function Remove-BadFiles ($files) {
    ForEach ($file in $files) {
        Add-Type -AssemblyName System.Drawing
        $img = [Drawing.Image]::FromFile($file)
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

if(-not (Test-Path $destination)) { New-Item -Path $destination -ItemType Directory }

try { 
    Get-Wallpapers $destination
}
catch {
    Write-Error "An error occurred attempting to download images from EarthPorn!"
}
finally {
    $files = (Get-ChildItem $destination -Filter *.jpg).FullName
    Remove-BadFiles $files
}