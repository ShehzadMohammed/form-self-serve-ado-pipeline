# Microsoft Visual C++ Build Tools Installation Script
# This script resolves the "microsoft visual c++ 14.0 or greater is required" error

Write-Host "=== Microsoft Visual C++ Build Tools Installation ===" -ForegroundColor Cyan
Write-Host ""

# Method 1: Download and install Visual Studio Build Tools
Write-Host "Method 1: Visual Studio Build Tools (Recommended)" -ForegroundColor Yellow
Write-Host "1. Download Visual Studio Build Tools:" -ForegroundColor White
Write-Host "   https://aka.ms/vs/17/release/vs_buildtools.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Run the installer and select:" -ForegroundColor White
Write-Host "   - C++ build tools" -ForegroundColor Gray
Write-Host "   - Windows 10/11 SDK" -ForegroundColor Gray
Write-Host "   - CMake tools (optional)" -ForegroundColor Gray
Write-Host ""

# Method 2: Automated download and installation
Write-Host "Method 2: Automated Installation" -ForegroundColor Yellow
Write-Host "Run the following commands to download and install automatically:" -ForegroundColor White
Write-Host ""

$downloadCommand = @"
# Download Visual Studio Build Tools
`$buildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
`$buildToolsPath = "vs_buildtools.exe"
Write-Host "Downloading Visual Studio Build Tools..." -ForegroundColor Green
Invoke-WebRequest -Uri `$buildToolsUrl -OutFile `$buildToolsPath

# Install with C++ workload
Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Green
Write-Host "This may take several minutes..." -ForegroundColor Yellow
Start-Process -FilePath `$buildToolsPath -ArgumentList "--quiet", "--wait", "--add", "Microsoft.VisualStudio.Workload.VCTools", "--includeRecommended" -Wait

# Clean up
Remove-Item `$buildToolsPath -Force
Write-Host "Installation complete!" -ForegroundColor Green
"@

Write-Host $downloadCommand -ForegroundColor Gray
Write-Host ""

# Method 3: Alternative - Use pre-compiled wheels only
Write-Host "Method 3: Alternative - Use Pre-compiled Wheels Only" -ForegroundColor Yellow
Write-Host "If you want to avoid installing build tools, try:" -ForegroundColor White
Write-Host ""

$precompiledCommand = @"
# Upgrade pip first
pip install --upgrade pip

# Install only pre-compiled wheels (no compilation)
pip install --only-binary=:all: cffi cryptography

# If that fails, try specific versions known to have wheels
pip install cffi==1.15.1 cryptography==41.0.7

# Install remaining requirements
pip install -r requirements-full.txt --only-binary=:all:
"@

Write-Host $precompiledCommand -ForegroundColor Gray
Write-Host ""

# Method 4: Using conda (if available)
Write-Host "Method 4: Using Conda (If Available)" -ForegroundColor Yellow
Write-Host "If you have conda installed:" -ForegroundColor White
Write-Host ""

$condaCommand = @"
# Install cffi and cryptography via conda
conda install cffi cryptography

# Then install remaining packages with pip
pip install -r requirements-full.txt
"@

Write-Host $condaCommand -ForegroundColor Gray
Write-Host ""

# Verification commands
Write-Host "=== Verification Commands ===" -ForegroundColor Cyan
Write-Host "After installation, verify with:" -ForegroundColor White
Write-Host ""

$verifyCommand = @"
# Test cffi installation
python -c "import cffi; print('cffi version:', cffi.__version__)"

# Test cryptography installation  
python -c "import cryptography; print('cryptography version:', cryptography.__version__)"

# Install all requirements
pip install -r requirements-full.txt
"@

Write-Host $verifyCommand -ForegroundColor Gray
Write-Host ""

Write-Host "=== Quick Start ===" -ForegroundColor Green
Write-Host "For immediate resolution, copy and paste this command block:" -ForegroundColor White
Write-Host ""
Write-Host "# Quick fix - try pre-compiled wheels first" -ForegroundColor Cyan
Write-Host "pip install --upgrade pip" -ForegroundColor White
Write-Host "pip install --only-binary=:all: cffi==1.15.1 cryptography==41.0.7" -ForegroundColor White
Write-Host "pip install -r requirements-full.txt" -ForegroundColor White
Write-Host ""

Write-Host "If the quick fix fails, run the automated installation commands above." -ForegroundColor Yellow
