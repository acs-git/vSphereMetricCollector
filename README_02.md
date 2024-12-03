# VMware Metrics Collection Tool

A PowerShell-based tool for collecting performance metrics from VMware vCenter environments.

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
