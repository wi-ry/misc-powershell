# misc-powershell
Miscellaneous PowerShell Scripts

## Get-RedditWallpapers.ps1
Added options, so you can now do things like this:
.\Get-RedditWallpapers.ps1 -subReddit ultrahdwallpapers (Defaults to 'EarthPorn')
.\Get-RedditWallpapers.ps1 -wallpaperRoot D:\alternateRoot (Defaults to 'C:\Wallpapers')
.\Get-RedditWallpapers.ps1 -minWidth 1920 -minHeight 1200 (Defaults to '1920' x '1080')

This script will pull the latest 100 images down from a given subreddit, and remove ones that are the wrong orientation or low resolution.

It's a little rough around the edges. Feel free to improve upon it! I recently changed the script to use Ed Wilson's "Get-FileMetaData" function rather than "System.Drawing.Image" assembly.

## New-GeneratedPassword.ps1
Creates one or more passwords. Options include password length, minimum number of non-alphanumeric characters, and number of passwords to be generated. Returns an array of values.
