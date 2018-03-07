# This could be expanded a lot, but it's a start
function New-RandomString ([int]$length = 20) {
	-join ((65..90) + (97..122) | Get-Random -Count $length | % {[char]$_})
}
