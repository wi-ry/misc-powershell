# misc-powershell
Miscellaneous PowerShell Scripts


## Get-RedditWallpapers.ps1
This script will pull the latest 100 images down from a given subreddit.

Parameters available:
* `sort` - "new", "top", "hot" or "rising" [Defaults to `new`]
* `subReddits` Array of subreddits [Defaults to `"EarthPorn","Wallpapers"`]
* `wallpaperRoot` [Defaults to `C:\Wallpapers`]
* `minWidth` / `minHeight` [Defaults to width `1920` and height `1080`]
* `ignorePortrait` - Ignore portrait images (`$true`) or include them (`$false`) [Defaults to `$true`]

Examples:
* `.\Get-RedditWallpapers.ps1 -subReddits EarthPorn,Pics,Wallpapers`
* `.\Get-RedditWallpapers.ps1 -wallpaperRoot D:\alternateRoot`
* `.\Get-RedditWallpapers.ps1 -minWidth 1920 -minHeight 1200`
* `.\Get-RedditWallpapers.ps1 -sort rising`
* `.\Get-RedditWallpapers.ps1 -ignorePortrait $false`


## Get-LockScreenWallpapers.ps1
Windows 10/11 is constantly updating your lock screen with its curated, personalized slideshow of images in Windows Spotlight.

This script will copy all the desktop wallpapers from `$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets` to a directory automatically! Just update the first line of the script with your desired destination.


## New-GeneratedPassword.ps1
Creates one or more passwords. Options include password length, minimum number of non-alphanumeric characters, and number of passwords to be generated. Returns an array of values.


## New-RandomString.ps1
Generates a random string of the given length. Defaults to 20 characters
