#Splunk Configuration Script for SCCM Task Sequence
#Locate Splunk based on the MSI registration

function Get-IniContent ($filePath) {
    $ini = @{ }
    $section = "GLOBAL"
    $CommentCount = 0
    switch -regex -file $FilePath {
 
        "^\[(.+)\]" { # Section
            $section = $matches[1]
            $ini[$section] = @{ }
            $CommentCount = 0
        }
        "^(\#.*)$" { # Comment
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            #$ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" { # Key
            $name, $value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

$location = "C:\Program Files\SplunkUniversalForwarder\"

#note if splunk may not be installed at the default location uncomment the following lines
#$list = Get-WmiOBject -Class Win32_Product | Where-Object {
# $_.Name -eq 'UniversalForwarder' -or $_.Name -eq 'Splunk' }

#$splunkprod = $list | where-Object { $_.InstallLocation }

#$location = $splunkprod.InstallLocation

$scriptappver = 2

$splunkcmd = $location + "bin\splunk.exe"
$staticapp = $location + "etc\apps\_static_all_universalforwarder\"
$staticdefault = $staticapp + "default\"
$staticlocal = $staticapp + "local\"

$staticdefault_dc = $staticdefault + "deploymentclient.conf"
$staticlocal_dc = $staticlocal + "deploymentclient.conf"
$staticdefault_app = $staticdefault + "app.conf"

if (!(Test-Path -Path $staticapp)) { new-item -ItemType Directory -Path $staticapp }

if (!(Test-Path -Path $staticdefault)) { new-item -ItemType Directory -Path $staticdefault }

if (!(Test-Path -Path $staticlocal)) { new-item -ItemType Directory -Path $staticlocal }

if (!(Test-Path -Path $staticdefault_app)) {
    new-item -path $staticdefault_app -ItemType File
    Add-Content -Path $staticdefault_app -Value "#Generated by scripting"
    #Add-Content -Path $staticdefault_app -Value "`r`n"
    Add-Content -Path $staticdefault_app -Value "[_static_all_universalforwarder]"
    Add-Content -Path $staticdefault_app -Value "author=Ryan Faircloth"
    Add-Content -Path $staticdefault_app -Value "description=Script Generated UF default configuration"
    Add-Content -Path $staticdefault_app -Value "version=1"
    Add-Content -Path $staticdefault_app -Value "[ui]"
    Add-Content -Path $staticdefault_app -Value "is_visible = false"
}

$appconf = Get-IniContent $staticdefault_app
$appver = $appconf["_static_all_universalforwarder"]["version"]

if ($appver -ne $scriptappver) {
    if (!(Test-Path -Path $staticdefault_dc)) {
        new-item -path $staticdefault_dc -ItemType File
        Add-Content -Path $staticdefault_dc -Value "#Generated by scripting"
        Add-Content -Path $staticdefault_dc -Value "[deployment-client]"
        Add-Content -Path $staticdefault_dc -Value "clientName=ScriptDeployed"
        Add-Content -Path $staticdefault_dc -Value "[target-broker:deploymentServer]"
        Add-Content -Path $staticdefault_dc -Value "targetUri=server2:8089"
        Add-Content -Path $staticdefault_dc -Value ""

    }

    & $splunkcmd "restart"
}