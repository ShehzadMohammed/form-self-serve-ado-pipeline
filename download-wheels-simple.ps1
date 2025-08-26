# Simple wheel download script
Write-Host "Downloading all wheels for offline installation..." -ForegroundColor Green

# Clean and create wheels directory
if (Test-Path "wheels") {
    Remove-Item "wheels" -Recurse -Force
}
New-Item -ItemType Directory -Name "wheels"

# Download Python installer if not exists
$pythonInstaller = "python-3.11.9-amd64.exe"
if (!(Test-Path $pythonInstaller)) {
    Write-Host "Downloading Python installer..." -ForegroundColor Yellow
    $url = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
    Invoke-WebRequest -Uri $url -OutFile $pythonInstaller
}

# Download wheels using the comprehensive requirements
Write-Host "Downloading wheels..." -ForegroundColor Yellow

# First try to download platform-specific wheels (faster, no compilation needed)
Write-Host "Attempting to download pre-compiled wheels for Windows..." -ForegroundColor Cyan
pip download -r requirements-full.txt -d wheels/ --platform win_amd64 --only-binary=:all: --prefer-binary

# If that fails, download with compilation support
if ($LASTEXITCODE -ne 0) {
    Write-Host "Pre-compiled wheels not available for some packages, downloading with source support..." -ForegroundColor Yellow
    pip download -r requirements-full.txt -d wheels/ --prefer-binary
}

# Download Visual Studio Build Tools installer if cffi compilation might be needed
$buildToolsInstaller = "vs_buildtools.exe"
if (!(Test-Path $buildToolsInstaller)) {
    Write-Host "Downloading Visual Studio Build Tools (needed for cffi compilation)..." -ForegroundColor Yellow
    $buildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
    try {
        Invoke-WebRequest -Uri $buildToolsUrl -OutFile $buildToolsInstaller
        Write-Host "Build tools downloaded successfully" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not download build tools. Manual download may be required." -ForegroundColor Yellow
    }
}

Write-Host "Download complete!" -ForegroundColor Green
Write-Host "Wheels directory contains:" -ForegroundColor Cyan
Get-ChildItem wheels/ | Measure-Object | ForEach-Object { Write-Host "  $($_.Count) wheel files" }

Write-Host ""
Write-Host "Build the Docker image with:" -ForegroundColor Yellow
Write-Host "  docker build -t self-serve-ado ." -ForegroundColor White
