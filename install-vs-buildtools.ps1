# Install Visual Studio Build Tools - Executable Script
Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Green

# Download Build Tools installer
$buildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
$buildToolsPath = "vs_buildtools.exe"

Write-Host "Downloading Visual Studio Build Tools installer..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $buildToolsUrl -OutFile $buildToolsPath

Write-Host "Installing C++ Build Tools..." -ForegroundColor Yellow
Write-Host "This will take several minutes. Please wait..." -ForegroundColor Cyan

# Install with C++ workload silently
Start-Process -FilePath $buildToolsPath -ArgumentList "--quiet", "--wait", "--add", "Microsoft.VisualStudio.Workload.VCTools", "--includeRecommended" -Wait

# Clean up installer
Remove-Item $buildToolsPath -Force

Write-Host "Visual Studio Build Tools installation complete!" -ForegroundColor Green
Write-Host "You can now install Python packages that require compilation." -ForegroundColor Cyan
