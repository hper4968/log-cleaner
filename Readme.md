## Generate Logs

```
.\generate_logs.ps1
```

## Look for LastWriteTime of the files
```
(Get-Item "C:\Path\To\File.log").LastWriteTime
```

## Log Cleanup

### Execution command

```
.\logCleanup.ps1 `
  -DaysOld 15 `
  -LogDirectory "C:\Users\YourName\Desktop\Logs" `
  -ReportPath "C:\Users\YourName\Desktop\deleted_log_report.txt" `
  -S3BucketPath "s3://my-log-bucket/cleanup-reports/"

```