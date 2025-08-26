# CFFI Troubleshooting Script
Write-Host "=== CFFI Dependency Troubleshooting ===" -ForegroundColor Cyan
Write-Host ""

# Check Python version
Write-Host "Python Version:" -ForegroundColor Yellow
python --version
Write-Host ""

# Check pip version
Write-Host "Pip Version:" -ForegroundColor Yellow
pip --version
Write-Host ""

# Check if Microsoft Visual C++ tools are available
Write-Host "Checking for Microsoft Visual C++ Build Tools..." -ForegroundColor Yellow
try {
    $vsInstances = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\VisualStudio" -ErrorAction SilentlyContinue
    if ($vsInstances) {
        Write-Host "Visual Studio installations found:" -ForegroundColor Green
        $vsInstances | ForEach-Object { Write-Host "  $($_.Name)" }
    } else {
        Write-Host "No Visual Studio installations detected" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not check Visual Studio installations" -ForegroundColor Yellow
}
Write-Host ""

# Check available cffi versions
Write-Host "Checking available cffi versions..." -ForegroundColor Yellow
pip index versions cffi
Write-Host ""

# Try to find cffi wheels for current platform
Write-Host "Searching for cffi wheels compatible with current platform..." -ForegroundColor Yellow
$tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
try {
    pip download cffi --dest $tempDir --only-binary=:all: --prefer-binary
    Write-Host "Pre-compiled cffi wheel found!" -ForegroundColor Green
    Get-ChildItem $tempDir | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Cyan }
} catch {
    Write-Host "No pre-compiled cffi wheel available for this platform" -ForegroundColor Red
    Write-Host "Source compilation will be required" -ForegroundColor Yellow
} finally {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host ""

# Suggest solutions
Write-Host "=== Recommended Solutions ===" -ForegroundColor Cyan
Write-Host "1. Try upgrading pip: pip install --upgrade pip" -ForegroundColor White
Write-Host "2. Install specific cffi version: pip install cffi==1.15.1" -ForegroundColor White
Write-Host "3. Install Microsoft Visual C++ Build Tools if compilation is needed" -ForegroundColor White
Write-Host "4. Use pre-compiled wheels: pip install --only-binary=:all: cffi" -ForegroundColor White
Write-Host "5. Check requirements.txt for version conflicts" -ForegroundColor White
Write-Host ""

Write-Host "=== Troubleshooting Complete ===" -ForegroundColor Cyan
