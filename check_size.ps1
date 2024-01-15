$dateTime = Get-Date -Format "yyyy-MM-dd"
$settings = Get-Content "settings.txt" | ConvertFrom-StringData
$pass = Read-Host "Podaj haslo"

$servers = @()
$maxIndex = 0
foreach ($key in $settings.Keys) {
    if ($key -match '^name(\d+)$') {
        $index = [int]$Matches[1]
        if ($index -gt $maxIndex) {
            $maxIndex = $index
        }
    }
}

$runspacePool = [runspacefactory]::CreateRunspacePool(1, 20)
$runspacePool.Open()

$results = @()

$timer = [System.Diagnostics.Stopwatch]::StartNew()

$syncObject = [System.Threading.Mutex]::new()

for ($i = 1; $i -le $maxIndex; $i++) {
    $name = $settings.("name$i")
    $ip = $settings.("ip$i")
    $port = $settings.("port$i")

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($ip) -or [string]::IsNullOrWhiteSpace($port)) {
        # Skip the iteration if any of the server details are empty
        continue
    }

    $servers += [PSCustomObject]@{
        Name = $name
        IP = $ip
        Port = $port
    }

    $scriptBlock = {
        param($name, $ip, $port, $pass, $dateTime)
        
        Write-Output "Executing command on Server: $name, IP: $ip, Port: $port"
        Write-Output "Firma $name $ip $port" >> "C:\Check Size\testy\baza\${name}_baza_$dateTime.txt"
        Start-Sleep -Milliseconds 100
		$cplink = 'echo y | plink -ssh $ip -P $port -l root -pw $pass'
		$df = "df -h"
        $result = Invoke-Expression $cplink `"$df`"
        Start-Sleep -Milliseconds 100
        $result >> "C:\Check Size\testy\baza\${name}_baza_$dateTime.txt"		
        Write-Output "=====================================================================" >> "C:\Check Size\testy\baza\${name}_baza_$dateTime.txt"
        Write-Host "Executing command on Server: $name, IP: $ip, Port: $port"
    }

    $powershell = [powershell]::Create()
    $powershell.RunspacePool = $runspacePool
    $powershell.AddScript($scriptBlock.ToString())
    $powershell.AddParameter('name', $name)
    $powershell.AddParameter('ip', $ip)
    $powershell.AddParameter('port', $port)
    $powershell.AddParameter('pass', $pass)
    $powershell.AddParameter('dateTime', $dateTime)

    $handle = $powershell.BeginInvoke()
    $results += [PSCustomObject]@{
        Name = $name
        Handle = $handle
    }
}

$runspacePool.Close()
$runspacePool.Dispose()

# Wait for all PowerShell jobs to complete
$allJobsCompleted = $false

do {
    $allJobsCompleted = $true
    Start-Sleep -Milliseconds 5000
    foreach ($result in $results) {
        if (-not $result.Handle.IsCompleted) {
            $allJobsCompleted = $false
            break
        }
    }
} while (-not $allJobsCompleted)

$timer.Stop()
$executionTime = $timer.Elapsed.ToString()

# Write the execution time to a separate file
$timeFile = "C:\Check Size\testy\baza\execution_time_$dateTime.txt"
$executionTime | Out-File -FilePath $timeFile

# Combine all the individual files into one
$files = Get-ChildItem "C:\Check Size\testy\baza" -Filter "*_baza_$dateTime.txt" | Select-Object -ExpandProperty FullName

$outputFile = "C:\Check Size\testy\baza\combined_$dateTime.txt"

Get-Content $files | Set-Content $outputFile

$results
