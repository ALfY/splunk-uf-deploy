
$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'UniversalForwarder'"

$app.Uninstall()