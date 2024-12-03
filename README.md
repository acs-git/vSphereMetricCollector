# VMware Metrics Collection Tool

A PowerShell-based tool for collecting performance metrics from VMware vCenter environments to assess for potential optimization opportunities.

## Download Instructions

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

### About the Files
- `collection_input_gui.ps1`: Provides a graphical user interface for inputting vCenter connection and collection parameters
- `01_Collection.ps1`: The main script that collects metrics from vSphere based on the parameters provided through the GUI

## Prerequisites

### System Requirements
- PowerShell 5.1 or later
  - *While the tool may work on later versions, it has been primarily tested on PowerShell 5.1*
  - *If you encounter issues, please report your PowerShell version*
- Administrator rights to the target vCenter
- Network connectivity to vCenter Server on TCP port 443
- Sufficient storage space in output directory

### PowerShell Configuration
- Local execution policy must allow running unsigned scripts
  - Example: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
- PowerCLI module
  - *The script will automatically check and install if missing*

For detailed information about PowerShell execution policies, including security implications and available options, please refer to the official Microsoft documentation:
[About Execution Policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)

### Access Requirements
- Administrator credentials for the target vCenter
- System running the script must have:
  - Network access to vCenter (TCP/443)
  - Permission to write to the specified output directory
  - Internet access (for PowerCLI module installation if needed)

## Quick Start

1. Run the input GUI:
```powershell
.\collection_input_gui.ps1
```
2. Enter your vCenter details and collection preferences
3. Click Save to begin collection

## Input Parameters

### Required Fields
- **vCenter Server**: Your vCenter IP/FQDN
- **Username**: vCenter username
- **Password**: vCenter password (securely encrypted when saved)
- **Output Directory**: Where to save collected data

### Collection Settings
- **Metric Level**:
  - L1: Basic (CPU, memory, disk usage)
  - L2: Medium (adds network, ready states)
  - L3: Advanced (adds detailed system metrics)

- **History Level**:
  - H1: Last day
  - H2: Last week
  - H3: Last month
  - H4: Last year

- **Max File Size**: Size limit per output file (recommended: 30MB)

## Output Files

The script creates a directory named `VCenter-[vcenter_name]` containing:

1. `listVMs.csv`: VM inventory data
   - Hardware specs
   - Network config
   - Resource allocation
   - Power state
   - Guest OS information
   - Creation date
   - Resource pool assignment
   - Storage utilization

2. `vm_[name]_[histLevel]_[metricLevel].csv`: Performance metrics
   - Timestamps
   - Metric values
   - Collection intervals

## Configuration

The tool saves your settings in `collection_input.json`. This includes:
- vCenter connection details
- Collection preferences
- Output directory path
- Encrypted password for security

Note: Never share the `collection_input.json` file as it contains sensitive information.

## Tips

- Start with L1 metrics and H4 history for baseline collection
- Use domain credentials when possible
- Ensure sufficient disk space in output directory
- VMware PowerCLI module will auto-install if needed

## Assessment Questionnaire

To maximize the value of collected metrics, please provide information about your environment:

### Resource Allocation and Overcommitment

1. Do you use physical or logical compute separation for different workload categories?
2. What levels of separation are in use?
   - Clusters
   - Hosts
   - Resource Pools
   - vApps
   - VM Reservations
3. Current overcommit ratios/policies for:
   - CPU
   - Memory
4. Known performance issues or bottlenecks
5. Other resource allocation considerations

### Dependencies and Constraints

1. Restrictive OS or application licensing models
2. Special licensing considerations:
   - SQL
   - Oracle
   - Licensing audits requiring host access
   - Per-core licensing
3. Non-virtualizable dependencies:
   - RDMs
   - Direct-attached storage
   - Shared disks (Quorum)
   - Application clustering (MSCS, RAC)

### Network and Security

1. L3 routing technologies
2. Remote access solutions:
   - IPSec site-to-site
   - SSL VPN
   - MPLS
3. Load balancing:
   - L4/L7 capabilities
   - SSL offloading
4. WAN optimization
5. Firewall implementation
6. Security measures:
   - Defense in depth
   - WAF deployment
   - IDS/IPS
   - Antivirus (agent/agentless)
7. CDN usage
8. Additional network services/features
12. If possible, please complete a table of Network and Security assets with a summary of purpose/features similar to the following table:

| Asset Type | Vendor/Product | Version | Location | Purpose/Features |
|------------|---------------|----------|-----------|------------------|
| Firewall   |               |          |           |                  |
| Load Balancer |            |          |           |                  |
| IDS/IPS    |               |          |           |                  |
| WAF        |               |          |           |                  |
| VPN        |               |          |           |                  |
| Anti-Virus |               |          |           |                  |

Please provide this information along with the collected metrics for comprehensive environment assessment.
