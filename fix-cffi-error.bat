@echo off
REM Fix for "microsoft visual c++ 14.0 or greater is required" error

echo === Fixing CFFI Compilation Error ===
echo.

echo Method 1: Try pre-compiled wheels (Quick Fix)
echo ============================================
echo pip install --upgrade pip
echo pip install --only-binary=:all: cffi==1.15.1 cryptography==41.0.7
echo pip install -r requirements-full.txt
echo.

echo Method 2: Install Visual Studio Build Tools
echo ===========================================
echo Download from: https://aka.ms/vs/17/release/vs_buildtools.exe
echo.
echo Or run this PowerShell command:
echo powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile 'vs_buildtools.exe'"
echo vs_buildtools.exe --quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended
echo.

echo Method 3: Manual Installation Steps
echo ===================================
echo 1. Download Visual Studio Installer from: https://visualstudio.microsoft.com/downloads/
echo 2. Select "Build Tools for Visual Studio 2022"
echo 3. In the installer, check "C++ build tools"
echo 4. Click Install
echo.

echo === Quick Commands to Copy/Paste ===
echo.
echo REM Quick fix attempt:
echo pip install --upgrade pip
echo pip install --only-binary=:all: cffi==1.15.1
echo pip install --only-binary=:all: cryptography==41.0.7  
echo pip install -r requirements-full.txt
echo.

pause
