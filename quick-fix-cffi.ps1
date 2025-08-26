# Quick Fix for CFFI Error - Executable Commands
Write-Host "=== Quick Fix for microsoft visual c++ 14.0 error ===" -ForegroundColor Green
Write-Host ""

# Method 1: Try pre-compiled wheels first (fastest solution)
Write-Host "Attempting quick fix with pre-compiled wheels..." -ForegroundColor Yellow

try {
    Write-Host "Step 1: Upgrading pip..." -ForegroundColor Cyan
    pip install --upgrade pip
    
    Write-Host "Step 2: Installing cffi with pre-compiled wheel..." -ForegroundColor Cyan
    pip install --only-binary=:all: cffi==1.15.1
    
    Write-Host "Step 3: Installing cryptography with pre-compiled wheel..." -ForegroundColor Cyan
    pip install --only-binary=:all: cryptography==41.0.7
    
    Write-Host "Step 4: Installing remaining requirements..." -ForegroundColor Cyan
    pip install -r requirements-full.txt
    
    Write-Host "SUCCESS: All packages installed successfully!" -ForegroundColor Green
    
    # Test the installation
    Write-Host "Testing installation..." -ForegroundColor Cyan
    python -c "import cffi; print('cffi version:', cffi.__version__)"
    python -c "import cryptography; print('cryptography version:', cryptography.__version__)"
    
} catch {
    Write-Host "Quick fix failed. You need to install Visual Studio Build Tools." -ForegroundColor Red
    Write-Host ""
    Write-Host "Download and install from: https://aka.ms/vs/17/release/vs_buildtools.exe" -ForegroundColor Yellow
    Write-Host "Select 'C++ build tools' during installation" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or run the automated installer:" -ForegroundColor Cyan
    Write-Host ".\install-build-tools.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "Script complete!" -ForegroundColor Green
