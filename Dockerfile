# Use Windows Server Core as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set shell to cmd
SHELL ["cmd", "/S", "/C"]

# Create app directory
WORKDIR C:\\app

# Copy Python installer (you need to download this beforehand and place in build context)
# Download from: https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
COPY python-3.11.9-amd64.exe C:\\temp\\python-installer.exe

# Install Python silently using cmd
RUN C:\temp\python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 && \
    del C:\temp\python-installer.exe

# Install Microsoft Visual C++ Build Tools (needed for cffi compilation)
# Download from: https://aka.ms/vs/17/release/vs_buildtools.exe
COPY vs_buildtools.exe C:\\temp\\vs_buildtools.exe
RUN C:\temp\vs_buildtools.exe --quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended && \
    del C:\temp\vs_buildtools.exe

# Update PATH for current and future sessions
ENV PATH="C:\Program Files\Python311;C:\Program Files\Python311\Scripts;C:\Windows\system32;C:\Windows"

# Copy requirements and download wheels offline
# Note: You need to download wheel files beforehand using:
# pip download -r requirements.txt -d wheels/
COPY wheels/ C:\\app\\wheels\\
COPY requirements-full.txt C:\\app\\

# Install all packages from local wheels
RUN python -m pip install --no-index --find-links C:\app\wheels -r requirements-full.txt

# Copy application files
COPY . C:\\app\\

# Expose port
EXPOSE 8080

# Set environment variables
ENV FLASK_APP=server.py
ENV FLASK_ENV=production

# Run the application
CMD ["python", "server.py"]