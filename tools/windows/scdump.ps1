#
# Shellcode dumping script. 
#
# Usage:
#     powershell ./scdump.ps1 w32-exec-calc-shellcode.exe
#
# dumpbin.exe must be in PATH!
#
# Author: Oleg Mitrofanov (reider-roque) 2015
#


Param ( [String]$filepath = "" )

if ($filepath -eq "") {
    Write-Host "`nUsage: .\scdump.ps1 FILEPATH`n"
    exit
}

if (!(Test-Path $filepath)) {
    Write-Host "`nError: file ""$filepath"" not found.`n"
    exit
}

$matches = dumpbin /disasm $filepath | Select-String -NotMatch ".*Microsoft.*|.*file.*|^\s*$" 

$opcodes = ''
$i = 0
foreach ($match in $matches) 
{
    if ($match.line.Contains("Summary")) { Break; }

    $len = $match.line.Length
    if ($len -gt 29) {
        $opcodes += " " + $match.line.substring(12, 17)
    }
    else {
        $opcodes += " " + $match.line.substring(12, $len-12)       
    }
}

$shellcode = $opcodes |`
    % { $_ -replace " *", "" } |`     # Squeeze all spaces
    % { $_ -replace ".{2}", "\x$&" }  # Inset \x every two chars

Write-Host "`nLength:" ($shellcode.Length / 4)
Write-Host "Shellcode: ""$shellcode""`n"