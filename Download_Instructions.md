# How to Download vSphere Metric Collector Files

To download the required files from the vSphere Metric Collector repository, follow these steps:

1. Navigate to the following direct file URLs:
   - [collection_input_gui.ps1](https://raw.githubusercontent.com/acs-git/vSphereMetricCollector/main/collection_input_gui.ps1)
   - [01_Collection.ps1](https://raw.githubusercontent.com/acs-git/vSphereMetricCollector/main/01_Collection.ps1)

2. For each file:
   - Right-click on the link
   - Select "Save link as..." or "Save target as..."
   - Choose a location on your computer to save the file
   - Keep the original filename (collection_input_gui.ps1 and 01_Collection.ps1)

Alternative Method (Using PowerShell):

1. Open PowerShell
2. Run the following commands:
```powershell
# Create a directory for the files (optional)
New-Item -ItemType Directory -Path ".\vSphereMetricCollector" -Force
cd .\vSphereMetricCollector

# Download the files
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/acs-git/vSphereMetricCollector/main/collection_input_gui.ps1" -OutFile "collection_input_gui.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/acs-git/vSphereMetricCollector/main/01_Collection.ps1" -OutFile "01_Collection.ps1"
```

## PowerShell Execution Policy

Before running the PowerShell scripts, you may need to adjust your PowerShell execution policy. The execution policy is a security feature that controls the conditions under which PowerShell loads configuration files and runs scripts.

To run these scripts, you might need to set an appropriate execution policy using one of these commands:
```powershell
# Run as administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Or
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

For detailed information about PowerShell execution policies, including security implications and available options, please refer to the official Microsoft documentation:
[About Execution Policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)

## About the Files
- `collection_input_gui.ps1`: Provides a graphical user interface for inputting vCenter connection and collection parameters
- `01_Collection.ps1`: The main script that collects metrics from vSphere based on the parameters provided through the GUI
