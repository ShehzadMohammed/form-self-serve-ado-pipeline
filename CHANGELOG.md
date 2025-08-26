# Changelog

## Version 2.0.0 - Pure Python Implementation

### 🎉 Major Changes
- **ELIMINATED cffi/cryptography dependencies** - No more Visual C++ build tools required!
- **Pure Python implementation** - Uses Azure CLI + REST API instead of Azure SDK
- **Simplified installation** - Just `pip install -r requirements.txt` and you're ready!

### ✅ What Changed
- Removed `azure-identity`, `azure-mgmt-web`, `azure-mgmt-resource` packages
- Replaced with direct Azure REST API calls using `requests`
- Authentication now uses Azure CLI (`az login`) instead of DefaultAzureCredential
- Removed all build tools and compilation requirements

### 🚀 Benefits
- **Faster installation** - No compilation time
- **Windows-friendly** - No Visual C++ build tools needed
- **Simpler deployment** - Pure Python packages only
- **Same functionality** - All features work exactly the same

### 📦 New Dependencies
- `Flask==2.3.3` (unchanged)
- `requests>=2.28.0` (new - pure Python)

### 🗑️ Removed Dependencies
- `azure-identity` (replaced with Azure CLI)
- `azure-mgmt-web` (replaced with REST API)
- `azure-mgmt-resource` (replaced with REST API) 
- `cffi` (no longer needed)
- `cryptography` (no longer needed)
- `pycparser` (no longer needed)

### 🔧 Installation
```bash
# Old way (required Visual C++ build tools)
pip install azure-identity azure-mgmt-web  # Would fail without build tools

# New way (pure Python)
pip install -r requirements.txt  # Just works!
python server.py
```

### 🐳 Docker Changes
- Removed Visual Studio Build Tools installation
- Simplified Dockerfile (no more wheel downloads)
- Faster Docker builds

### 🧪 Testing
Run the test script to verify everything works:
```bash
python test-setup.py
```

### 📋 Prerequisites
- Python 3.8+
- Azure CLI (`az login` for authentication)
- Access to Azure subscription

That's it! No more compilation headaches! 🎉
