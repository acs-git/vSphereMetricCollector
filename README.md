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
![Table 1](https://github.com/user-attachments/assets/35fd7e69-b063-4507-aa3c-b57de058a9a6)

### Prerequisites 
- The script has been developed and tested to run on Powershell\
**5**.**1**\
*It should also run on later versions but cannot be guaranteed, any issues please let us know what version of Powershell you are running.*
- Administrator rights to the selected vCenter
- The script will check if the required PowerCLI module is installed on the script that the script is run from, if it is not present it will attempt to install it
- The system running the script needs to be able to connect to the target vCenter Server on TCP port 443
- Please allow adequate storage in the selected output directory to store the collected data

It should also run on later versions but cannot be guaranteed, any issues please let us know what version of Powershell you are running.

### Script Instructions.
1. Download the `01_Collection.ps1` file from link provided by Ascend Cloud Solutions to the system capable of running the script.
2. Ensure script is run as system administrator and local Execution Policy settings allow the running of unsigned scripts [Execution Policy Settings](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)/ **Example:** `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`.
3. Open `01_Collection.ps1` in a preferred editor/IDE and fill out values for the required variables as outlined above.
4. Run the script in the preferred IDE or it can be run from a PowerShell command prompt by navigating to the directory the file exits in and running the following `.\01_Collection.ps1`.
5. Enter the vCenter username when prompted and press `enter`.
6. Enter vCenter password when prompted and press `enter`.
7. The script should now run, it can take some time depending on the size of the environment.

The output will be an arrray of CSV files with the name conventions `vms_H4_L3_10.csv (vms_’+
$histLevel+’_”+metricLevel+’_’+$counter+’.csv)`
The script will also produce a csv file with a list of vms including the parameters name, NumCpu, MemoryGB, VMHost, Folder, ResourcePool, Hardware Version, UsedSpaceGB, ProvisionedSPaceGB, CreateDate and moref.
Once complete please upload the outputted csv files as directed by Ascend Cloud Solutions.

# Questionaire

## Resource Allocation and Overcommitment
Gather any available information or guidance on current policies around resource overcommit or tiering. The purpose of this is to better equip ourselves when looking at any potential consolidation that may be possible in the cloud environment. If the information is not in hand we can work out current overcommits from the script output files.

1.	Do you use any physical or logical compute separation or tiering for different workload categories?
2.	If so, what levels of separation are currently in operation for this purpose?
   3.	Clusters   
   2.	Hosts
   3.	Resource Pools
   4.	vApps
   5.	VM Reservations
3.	Label each method used with an overcommit ratio or policy currently in use.
   1.	CPU
   2.	Memory
4.	Do you have any known regularly occurring performance issues or bottlenecks for production workloads?
5.	Any other relevant information regarding resource allocation please share here.


## Dependencies and Constraints Questionnaire

1.		In the estate to be migrated, do you have restrictive operating systems, or application licensing models in use that may affect cost at the destination environment?
   a.	SQL
   b.	Oracle
   c.	Licensing Audits that require unrestricted access to hosts etc.
   d.	Per available physical core licensing etc.
2.	Do you currently use any of the following
   a.	RDMs
   b.	Directly attached storage
   c.	Shared disks (Quorum)
   d.	Application Clustering (MSCS etc)
3.		In the estate to be migrated, are there any applications or other dependencies on non-virtualised assets that cannot be converted?
4.		Any other relevant information regarding resource constraints or dependencies please share here.



   
