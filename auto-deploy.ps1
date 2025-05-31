# Auto-deploy script for SeaBites deployment
# Watches for file changes and automatically commits and pushes to GitHub

param(
    [string]$CommitMessage = "Auto-deploy: Updated files at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

Write-Host "Starting auto-deploy watcher for SeaBites..." -ForegroundColor Green
Write-Host "Watching directory: $PWD" -ForegroundColor Yellow
Write-Host "Remote repository: https://github.com/Blunistark/SeaBites-deploy.git" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop watching..." -ForegroundColor Cyan

# Create file system watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $PWD
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Define what happens when a file changes
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Ignore git files and temporary files
    if ($path -match "\.git" -or $path -match "\.tmp" -or $path -match "~$") {
        return
    }
    
    Write-Host "[$timeStamp] File $changeType: $path" -ForegroundColor Yellow
    
    # Wait a bit to ensure file operations are complete
    Start-Sleep -Seconds 2
    
    try {
        # Add all changes
        Write-Host "Adding changes to git..." -ForegroundColor Cyan
        git add .
        
        # Check if there are any changes to commit
        $status = git status --porcelain
        if ($status) {
            # Commit changes
            Write-Host "Committing changes..." -ForegroundColor Cyan
            git commit -m $using:CommitMessage
            
            # Push to GitHub
            Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
            git push origin main
            
            Write-Host "✅ Successfully deployed changes!" -ForegroundColor Green
        } else {
            Write-Host "No changes to commit." -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "❌ Error during deployment: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Register event handlers
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Renamed" -Action $action

try {
    # Keep the script running
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    # Clean up
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "Auto-deploy watcher stopped." -ForegroundColor Red
} 