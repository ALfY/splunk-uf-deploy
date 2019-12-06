@ECHO OFF

GOTO:%~1 2>NUL

:install
    REM Install Splunk MSI
    msiexec.exe /i ".\splunkforwarder-7.3.3-7af3758d0d5e-x64-release.msi" /quiet AGREETOLICENSE=yes

    REM Run DS Pointer Script:
    Powershell.exe -executionpolicy remotesigned -File  ".\splunk_ds_config.ps1"
GOTO :EOF

:uninstall
    REM Remove the Splunk UF Software (if installed)
    REM If not installed, this will produce an error
    Powershell.exe -executionpolicy remotesigned -File ".\uninstall_uf.ps1"
GOTO :EOF