param(
    [int]$DaysOld = 30,
    [string]$LogDirectory = "C:<your-path>",  
    [string]$ReportPath = "C:<your-path>\deleted_log_report.txt",
    [string]$S3BucketPath = "s3://<s3-bucket>/logs/"
)

# Ensure the directory exists
if (!(Test-Path -Path $LogDirectory)) {
    Write-Host "Directory does not exist: $LogDirectory"
    exit 1
}

# Get the threshold date
$thresholdDate = (Get-Date).AddDays(-$DaysOld)
Write-Host "Deleting files older than $DaysOld days (before $thresholdDate)..."

# Get files older than the threshold
$filesToDelete = Get-ChildItem -Path $LogDirectory -File | Where-Object { $_.LastWriteTime -lt $thresholdDate }

$totalDeletedSize = 0
$deletedFileNames = @()

foreach ($file in $filesToDelete) {
    $totalDeletedSize += $file.Length
    $deletedFileNames += "$($file.FullName) (LastModified: $($file.LastWriteTime))"
    Remove-Item $file.FullName -Force
}

# Get disk usage info
$drive = Get-PSDrive -Name ($LogDirectory.Substring(0,1))
$totalDiskSize = $drive.Used + $drive.Free
$freedPercent = if ($totalDiskSize -gt 0) { [math]::Round(($totalDeletedSize / $totalDiskSize) * 100, 2) } else { 0 }

# Write report
$reportLines = @()
$reportLines += "Log Cleanup Report - $(Get-Date)"
$reportLines += "Deleted Files:"
$reportLines += $deletedFileNames
$reportLines += ""
$reportLines += "Total Deleted Size: $([math]::Round($totalDeletedSize / 1MB, 2)) MB"
$reportLines += "Freed Disk Space Percentage: $freedPercent %"
$reportLines | Out-File -FilePath $ReportPath -Encoding UTF8

Write-Host "Cleanup complete. Deleted $($filesToDelete.Count) files."
Write-Host "Report written to: $ReportPath"


Write-Host "Uploading report to S3: $S3BucketPath"
aws s3 cp $ReportPath $S3BucketPath
