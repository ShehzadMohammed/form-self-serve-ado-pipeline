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

# Clean wheels directory first
if (Test-Path "wheels") {
    Remove-Item "wheels/*" -Recurse -Force
    Write-Host "Cleaned existing wheels directory" -ForegroundColor Yellow
}

# First, download essential build tools
Write-Host "Downloading build tools..." -ForegroundColor Yellow
pip download pip setuptools wheel -d wheels/

# Download all dependencies with all transitive dependencies
Write-Host "Downloading application dependencies..." -ForegroundColor Yellow
pip download -r requirements.txt -d wheels/ --no-deps
pip download Flask azure-identity azure-mgmt-web azure-mgmt-resource -d wheels/
pip download cryptography cffi pycparser -d wheels/

# Download any missing dependencies by installing in a temp venv and capturing all wheels
Write-Host "Ensuring all transitive dependencies..." -ForegroundColor Yellow
$tempVenv = "temp_venv_for_deps"
python -m venv $tempVenv
& ".\$tempVenv\Scripts\activate.ps1"
pip install -r requirements.txt
pip freeze | ForEach-Object { 
    $package = $_.Split('==')[0]
    pip download $package -d wheels/ --no-deps
}
deactivate
Remove-Item $tempVenv -Recurse -Force

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
