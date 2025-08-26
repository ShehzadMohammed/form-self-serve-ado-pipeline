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
pip download -r requirements-full.txt -d wheels/ --platform win_amd64 --no-deps
pip download -r requirements-full.txt -d wheels/

Write-Host "Download complete!" -ForegroundColor Green
Write-Host "Wheels directory contains:" -ForegroundColor Cyan
Get-ChildItem wheels/ | Measure-Object | ForEach-Object { Write-Host "  $($_.Count) wheel files" }

Write-Host ""
Write-Host "Build the Docker image with:" -ForegroundColor Yellow
Write-Host "  docker build -t self-serve-ado ." -ForegroundColor White
