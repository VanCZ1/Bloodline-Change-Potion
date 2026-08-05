@echo off

pyro build.ppj --no-implicit-imports
if errorlevel 1 (
    echo ERROR: Build failed!
    pause >nul
    exit /b 1
)

echo.
echo Build complete!
echo Press any key to continue...
pause >nul
