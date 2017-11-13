[CmdletBinding()]
[Alias()]
[OutputType([int])]
param (
	[string]$wallpaperRoot = "C:\Wallpapers",
	[string]$subReddit = "EarthPorn",
	[int]$minWidth = 1920,
	[int]$minHeight = 1080
)

workflow Get-Wallpapers ($destination,$subReddit) {
	$images = Invoke-RestMethod https://www.reddit.com/r/$subReddit/new/.json -Method Get -Body @{limit="100"} | ForEach-Object { $_.data.children.data.url } | ? { $_ -match "\.jpg$" }
	$current = 0
	$total = $images.count
	Write-Output "Downloading images to $destination..."
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

Function Get-FileMetaData
{
  <# 
   .Synopsis 
    This function gets file metadata and returns it as a custom PS Object  
   .Description 
    This function gets file metadata using the Shell.Application object and 
    returns a custom PSObject object that can be sorted, filtered or otherwise 
    manipulated. 
   .Example 
    Get-FileMetaData -folder "e:\music" 
    Gets file metadata for all files in the e:\music directory 
   .Example 
    Get-FileMetaData -folder (gci e:\music -Recurse -Directory).FullName 
    This example uses the Get-ChildItem cmdlet to do a recursive lookup of  
    all directories in the e:\music folder and then it goes through and gets 
    all of the file metada for all the files in the directories and in the  
    subdirectories.   
   .Example 
    Get-FileMetaData -folder "c:\fso","E:\music\Big Boi" 
    Gets file metadata from files in both the c:\fso directory and the 
    e:\music\big boi directory. 
   .Example 
    $meta = Get-FileMetaData -folder "E:\music" 
    This example gets file metadata from all files in the root of the 
    e:\music directory and stores the returned custom objects in a $meta  
    variable for later processing and manipulation. 
   .Parameter Folder 
    The folder that is parsed for files  
   .Notes 
    NAME:  Get-FileMetaData 
    AUTHOR: ed wilson, msft 
    LASTEDIT: 01/24/2014 14:08:24 
    KEYWORDS: Storage, Files, Metadata 
    HSG: HSG-2-5-14 
   .Link 
     Http://www.ScriptingGuys.com 
 #Requires -Version 2.0 
 #> 
 Param([string[]]$folder) 
 foreach($sFolder in $folder) 
  { 
   $a = 0 
   $objShell = New-Object -ComObject Shell.Application 
   $objFolder = $objShell.namespace($sFolder) 
 
   foreach ($File in $objFolder.items()) 
    {  
     $FileMetaData = New-Object PSOBJECT 
      for ($a ; $a  -le 266; $a++) 
       {  
         if($objFolder.getDetailsOf($File, $a)) 
           { 
             $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a))  = 
                   $($objFolder.getDetailsOf($File, $a)) -replace([char]8206,"") -replace([char]8207,"") }
            $FileMetaData | Add-Member $hash 
            $hash.clear()
           } #end if 
       } #end for  
     $a=0 
     $FileMetaData 
    } #end foreach $file 
  } #end foreach $sfolder 
} #end Get-FileMetaData

function Remove-BadFiles {
	Write-Output "Analyzing files in $destination..."
	$files = Get-FileMetaData $destination
    ForEach ($file in $files) {
		[int]$fileHeight = $file.Height -replace(" pixels","")
		[int]$fileWidth = $file.Width -replace(" pixels","")
		if ($fileHeight -ge $fileWidth) {
            Remove-Item -Force (Join-Path -Path $destination -ChildPath $file.Name)
            Write-Output " * Removing $($file.Name) - Wrong orientation"
        }
        elseif (($fileWidth -lt $minWidth) -OR ($fileHeight -lt $minHeight)) {
            Remove-Item -Force (Join-Path -Path $destination -ChildPath $file.Name)
            Write-Output " * Removing $($file.Name) - Low resolution"
        }
    }
}

$destination = Join-Path -Path $wallpaperRoot -ChildPath $subReddit
if(-not (Test-Path $destination)) { New-Item -Path $destination -ItemType Directory | Out-Null }

try { 
    Get-Wallpapers $destination $subReddit
}
catch {
    Write-Error "An error occurred attempting to download images from $subReddit!"
}
finally {
    Write-Progress -Activity "Downloading images..." -Completed
    Remove-BadFiles
}
