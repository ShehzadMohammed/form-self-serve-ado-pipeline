# Use Windows Server Core as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Create app directory
WORKDIR C:\\app

# Copy Python installer (you need to download this beforehand and place in build context)
# Download from: https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
COPY python-3.11.9-amd64.exe C:\\temp\\python-installer.exe

# Install Python silently
RUN Start-Process -FilePath 'C:\temp\python-installer.exe' -ArgumentList '/quiet', 'InstallAllUsers=1', 'PrependPath=1', 'Include_test=0' -Wait; \
    Remove-Item 'C:\temp\python-installer.exe' -Force

# Add Python to PATH
RUN setx PATH $($Env:PATH + ';C:\Program Files\Python311;C:\Program Files\Python311\Scripts') /M

# Refresh environment variables
RUN refreshenv

# Copy requirements and download wheels offline
# Note: You need to download wheel files beforehand using:
# pip download -r requirements.txt -d wheels/
COPY wheels/ C:\\app\\wheels\\
COPY requirements.txt C:\\app\\

# Install packages from local wheels (no internet required)
RUN python -m pip install --no-index --find-links C:\app\wheels\ -r requirements.txt

# Copy application files
COPY . C:\\app\\

# Expose port
EXPOSE 8080

# Set environment variables
ENV FLASK_APP=server.py
ENV FLASK_ENV=production

# Run the application
CMD ["python", "server.py"]
