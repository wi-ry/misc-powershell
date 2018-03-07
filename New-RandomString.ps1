# This could be expanded a lot, but it's a start
function New-RandomString ([int]$length = 20, [int]$count = $null) {
	if($count -eq $null) { $count = 1}
	$i = 0
	while ($i -le $count) {
		-join ((65..90) + (97..122) | Get-Random -Count $length | % {[char]$_})
		$i++
	}
}
