$computers = Get-Content C:\list\computerlist.txt
$RegFile = "C:\list\access.reg"
foreach ($computer in $computers)
{
    if (Test-Connection -Computername $computer -Count 1 -ea 0 )
    {
        write-host $computer -ForegroundColor Green
        $newfile = "\\$computer\c$\Downloads\RegistryFiles\access.reg"
        New-Item -ErrorAction SilentlyContinue -ItemType directory -Path \\$computer\C$\Downloads\RegistryFiles
        Copy-Item $RegFile -Destination $newfile
        Invoke-Command -ComputerName $computer -ScriptBlock {
            Start-Process -filepath "C:\windows\regedit.exe" -argumentlist "/s C:\Downloads\RegistryFiles\access.reg" -Wait
        }
    }
    else
    {
        write-host $computer -ForegroundColor Red
        Add-Content -Path c:\list\nedostupni.txt -Value $computer
    }
}