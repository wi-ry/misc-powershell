<#
.SYNOPSIS
    Generates one or more random passwords
.DESCRIPTION
    Generates one or more random passwords using [System.Web.Security.Membership]::GeneratePassword
.EXAMPLE
    New-GeneratedPassword
.EXAMPLE
    New-GeneratedPassword -Length 25 -MinNonAlpha 5
.EXAMPLE
    New-GeneratedPassword -Length 25 -Count 10
#>
function New-GeneratedPassword {
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
            HelpMessage='The number of characters in the generated password. The length must be between 1 and 128 characters.')]
        [ValidateRange(1,128)]
        [int]$Length,

        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
            HelpMessage='The minimum number of non-alphanumeric characters in the generated password(s).')]
        [ValidateRange(1,128)]
        [int]$MinNonAlpha,
        
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
            HelpMessage='The number of passwords to be generated.')]
        [ValidateRange(1,100)]
        [int]$Count
    )
    
    begin {
        if(-not $Length) { [int]$Length = 15 }
        if(-not $MinNonAlpha) { [int]$MinNonAlpha = 0 }
        [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
        # Calling GeneratePassword Method 
        $list = @()
        $i = 1
    }
    
    process {
        if ($Count) {
            while ($i -le $Count) {
                # Write-Output "Current: $i -- Total: $multi"
                $list += [System.Web.Security.Membership]::GeneratePassword($Length,$MinNonAlpha)
                $i++
            }
        }
        else {
            $list += [System.Web.Security.Membership]::GeneratePassword($Length,$MinNonAlpha)
        }
    }
    
    end {
        return $list
    }
}