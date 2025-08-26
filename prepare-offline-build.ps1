# PowerShell script to prepare offline Docker build
# Run this script before building the Docker image

Write-Host "Preparing offline Docker build dependencies..." -ForegroundColor Green

# Create wheels directory
if (!(Test-Path "wheels")) {
    New-Item -ItemType Directory -Name "wheels"
    Write-Host "Created wheels directory" -ForegroundColor Yellow
}

# Download Python installer if not exists
$pythonInstaller = "python-3.11.9-amd64.exe"
if (!(Test-Path $pythonInstaller)) {
    Write-Host "Downloading Python installer..." -ForegroundColor Yellow
    $url = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
    Invoke-WebRequest -Uri $url -OutFile $pythonInstaller
    Write-Host "Downloaded Python installer" -ForegroundColor Green
} else {
    Write-Host "Python installer already exists" -ForegroundColor Green
}

# Download Python wheels for offline installation
Write-Host "Downloading Python package wheels..." -ForegroundColor Yellow
pip download -r requirements.txt -d wheels/ --no-deps
pip download -r requirements.txt -d wheels/

Write-Host "Offline build preparation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Files prepared:" -ForegroundColor Cyan
Write-Host "  - $pythonInstaller (Python installer)"
Write-Host "  - wheels/ directory (Python packages)"
Write-Host ""
Write-Host "You can now build the Docker image offline with:" -ForegroundColor Yellow
Write-Host "  docker build -t self-serve-ado ." -ForegroundColor White
Write-Host ""
Write-Host "To run the container:" -ForegroundColor Yellow
Write-Host "  docker run -p 8080:8080 self-serve-ado" -ForegroundColor White
