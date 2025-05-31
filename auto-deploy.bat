@echo off
echo Starting SeaBites Auto-Deploy...
echo Watching for changes in: %cd%
echo Press Ctrl+C to stop...

:watch_loop
timeout /t 10 /nobreak > nul

REM Check if there are any changes
for /f %%i in ('git status --porcelain') do (
    echo Changes detected! Deploying...
    git add .
    git commit -m "Auto-deploy: Updated at %date% %time%"
    git push origin main
    echo ✅ Deployment complete!
    goto watch_loop
)

goto watch_loop 