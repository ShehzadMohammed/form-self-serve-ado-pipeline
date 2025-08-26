# Download wheels for offline Docker build
Write-Host "=== Preparing Offline Build ===" -ForegroundColor Green
Write-Host ""

# Clean and create wheels directory
if (Test-Path "wheels") {
    Write-Host "Cleaning existing wheels directory..." -ForegroundColor Yellow
    Remove-Item "wheels" -Recurse -Force
}
New-Item -ItemType Directory -Name "wheels" | Out-Null

# Download Python installer if needed
$pythonInstaller = "python-3.11.9-amd64.exe"
if (!(Test-Path $pythonInstaller)) {
    Write-Host "Downloading Python installer..." -ForegroundColor Yellow
    $url = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
    try {
        Invoke-WebRequest -Uri $url -OutFile $pythonInstaller
        Write-Host "✓ Python installer downloaded" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to download Python installer" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Python installer already exists" -ForegroundColor Green
}

# Download wheels for offline installation
Write-Host "Downloading wheels for offline installation..." -ForegroundColor Yellow

try {
    # Download wheels for Windows platform
    pip download -r requirements-full.txt -d wheels/ --platform win_amd64 --prefer-binary
    
    # Also download any source packages as fallback
    pip download -r requirements-full.txt -d wheels/ --prefer-binary
    
    $wheelCount = (Get-ChildItem wheels/ -Filter "*.whl").Count
    Write-Host "✓ Downloaded $wheelCount wheel files" -ForegroundColor Green
    
} catch {
    Write-Host "✗ Failed to download wheels" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Offline Build Ready! ===" -ForegroundColor Green
Write-Host "Build the Docker image with:" -ForegroundColor Cyan
Write-Host "  docker build -t self-serve-ado ." -ForegroundColor White
Write-Host ""
Write-Host "Or for local development:" -ForegroundColor Yellow
Write-Host "  pip install -r requirements.txt" -ForegroundColor White
Write-Host "  python server.py" -ForegroundColor White
Write-Host ""

Write-Host "Files ready for offline deployment:" -ForegroundColor Cyan
Write-Host "  ✓ Python installer: $pythonInstaller" -ForegroundColor Gray
Write-Host "  ✓ Wheel files: wheels/ directory" -ForegroundColor Gray
Write-Host "  ✓ Requirements: requirements-full.txt" -ForegroundColor Gray
