# Define paths
$sourceBase = "$(Pipeline.Workspace)/s/templates/${{ parameters.subpath }}"
$targetBase = "$(Pipeline.Workspace)/s/self/$(workingdir)"

Write-Host "Source path: $sourceBase"
Write-Host "Target path: $targetBase"

# Create target directory
if (Test-Path $targetBase) {
    Remove-Item -Path $targetBase -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $targetBase

# Copy all terraform files
if (Test-Path $sourceBase) {
    Write-Host "Copying terraform files..."
    Copy-Item -Path "$sourceBase/*" -Destination $targetBase -Recurse -Force
    
    # Ensure env directory exists
    $envDir = "$targetBase/env"
    if (!(Test-Path $envDir)) {
    New-Item -ItemType Directory -Force -Path $envDir
    }
    
    # Create environment-specific tfvars if it doesn't exist
    $tfvarsFile = "$envDir/${{ parameters.environment }}.tfvars"
    if (!(Test-Path $tfvarsFile)) {
    Write-Host "Creating ${{ parameters.environment }}.tfvars..."
    @"
    # Environment-specific variables for ${{ parameters.environment }}
    environment = "${{ parameters.environment }}"
    infraenv = "$(infraenv)"

    # These values can be overridden by -var flags in commandOptions
    "@ | Out-File -FilePath $tfvarsFile -Encoding utf8
    }
    
    # List what was copied
    Write-Host "`nFinal structure:"
    Get-ChildItem -Path $targetBase -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Replace("$(Pipeline.Workspace)/s/self/", "")
    Write-Host $relativePath
    }
} else {
    Write-Error "Source terraform code not found at: $sourceBase"
    exit 1
}

# Set working directory for next steps
Write-Host "##vso[task.setvariable variable=System.DefaultWorkingDirectory]$(Pipeline.Workspace)/s/self"
