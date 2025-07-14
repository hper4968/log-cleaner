param(
    [string]$LogDirectory = "C:<file-path>\Logs",
    [int]$NumberOfFiles = 10
)

# Ensure the path is created
if (!(Test-Path -Path $LogDirectory)) {
    Write-Output "Creating directory: $LogDirectory"
    New-Item -ItemType Directory -Path $LogDirectory | Out-Null
}

# Generate mock logs
for ($i = 1; $i -le $NumberOfFiles; $i++) {
    $fileName = "mock_log_$i.log"
    $filePath = Join-Path $LogDirectory $fileName

    $logContent = @()
    for ($j = 1; $j -le (Get-Random -Minimum 10 -Maximum 50); $j++) {
        $timestamp = (Get-Date).AddMinutes(-$j).ToString("yyyy-MM-dd HH:mm:ss")
        $logContent += "$timestamp - INFO - Log entry $j from file $fileName"
    }

    $logContent | Out-File -FilePath $filePath -Encoding UTF8
    $daysOld = Get-Random -Minimum 1 -Maximum 60
    (Get-Item $filePath).LastWriteTime = (Get-Date).AddDays(-$daysOld)

    Write-Output "Generated: $filePath (LastWriteTime: $((Get-Item $filePath).LastWriteTime))"
}
