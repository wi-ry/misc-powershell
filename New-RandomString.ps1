# This could be expanded a lot, but it's a start
# Use '-incInt' to include numbers in strings generated

function New-RandomString ([int]$length = 20, [int]$count = $null, [switch]$incInt) {
	if($count -eq $null) { $count = 1}
	$i = 0
	while ($i -le $count) {
        if ($incInt) {
            -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $length | % {[char]$_})
        }
        else {
            -join ((65..90) + (97..122) | Get-Random -Count $length | % {[char]$_})
        }
		$i++
	}
}
