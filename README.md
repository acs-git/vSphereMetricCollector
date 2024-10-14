# vSphereMetricCollector

## Metric Collection
The aim of this script is to assess the customer's existing VMware
environments by analysing the available performance metric data and assessing for potential optimisation. 
Ascend Cloud Solutions experts will capture the necessary Host and VM data and provide
Customer with insight into VM’s actual utilisation of physical resources.
Metric collection script (using powershell/powercli) was created to
collect metrics as available in the vCenter. The variables on Table 1
need to be changed to match the customer environment. Please enter values for the `$vcenter` and `$OutputDir` variables, examples are in the below table.

You will be prompted for a username and password when the script is run. Other variables are configured with default settings and do not need to be changed unless explicitly instructed to do so. 
(![Table 1](https://github.com/user-attachments/assets/35fd7e69-b063-4507-aa3c-b57de058a9a6)

### Prerequisites 
- The script has been developed and tested to run on Powershell\
**5**.**1**\
*It should also run on later versions but cannot be guaranteed, any issues please let us know what version of Powershell you are running.*
- Administrator rights to the selected vCenter
- The script will check if the required PowerCLI module is installed on the script that the script is run from, if it is not present it will attempt to install it
- The system running the script needs to be able to connect to the target vCenter Server on TCP port 443
- Please allow adequate storage in the selected output directory to store the collected data

It should also run on later versions but cannot be guaranteed, any issues please let us know what version of Powershell you are running.

### Instructions.
1. Download the `01_Collection.ps1` file from link provided by Ascend Cloud Solutions to the system capable of running the script.
2. Ensure script is run as system administrator and local Execution Policy settings allow the running of unsigned scripts [Execution Policy Settings](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)/ **Example:** `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`.
3. Open `01_Collection.ps1` in a preferred editor/IDE and fill out values for the required variables as outlined above.
4. Run the script in the preferred IDE or it can be run from a PowerShell command prompt by navigating to the directory the file exits in and running the following `.\01_Collection.ps1`.
5. Enter the vCenter username when prompted and press `enter`.
6. Enter vCenter password when prompted and press `enter`.
7. The script should run, it can take some time depending on the size of the environment. Once complete please upload the outputted excel files as directed by Ascend Cloud Solutions.
   
