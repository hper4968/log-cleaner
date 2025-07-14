param (
    [string]$TaskName = "DailyLogCleanup",
    [string]$ScriptPath = "C:<file-path>\scheduleCleanupTask.ps1",
    [string]$StartTime = "02:00"  # Format: HH:mm (24-hour clock)
)

# Validate script file
if (!(Test-Path -Path $ScriptPath)) {
    Write-Error "The script path $ScriptPath does not exist."
    exit 1
}

# Define the scheduled task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Define the trigger time (daily)
$timeParts = $StartTime.Split(":")
$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours($timeParts[0]).AddMinutes($timeParts[1]))

# Run as SYSTEM user
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Runs logCleanup.ps1 daily at $StartTime" `
    -Force

Write-Host "Scheduled task '$TaskName' has been created to run daily at $StartTime."
