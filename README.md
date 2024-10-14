# vSphere Quick Assessment

## Metric Collection
This script aims to assess the customer's existing VMware
environments by analysing the available performance metric data and assessing for potential optimisation. 
Ascend Cloud Solutions experts will capture the necessary Host and VM data and provide
Customer with insight into VM’s actual utilisation of physical resources.
A metric collection script (using powershell/powercli) was created to
collect metrics as available in the vCenter. 
The variables on the script need to be changed to match the customer environment.  Please enter values for the `$vcenter` and `$OutputDir` variables, examples are in the below table.
![Table 1](https://github.com/user-attachments/assets/35fd7e69-b063-4507-aa3c-b57de058a9a6)\
When the script is run, you will be prompted for a username and password. Other variables are configured with default settings and do not need to be changed unless explicitly instructed to do so. 

### Prerequisites 
- The script has been developed and tested to run on Powershell\
**5**.**1**\
*It should also run on later versions but cannot be guaranteed, any issues please let us know what version of Powershell you are running.*
- Administrator rights to the selected vCenter
- The script will check if the required PowerCLI module is installed on the script that the script is run from, if it is not present it will attempt to install it
- The system running the script needs to be able to connect to the target vCenter Server on TCP port 443
- Please allow adequate storage in the selected output directory to store the collected data

### Script Instructions.
1. Download the `01_Collection.ps1` file from the [Ascend Cloud Solution Github](https://github.com/acs-git/vSphereMetricCollector/blob/main/01_Collection.ps1) to the system capable of running the script.
2. Ensure script is run as system administrator and local Execution Policy settings allow the running of unsigned scripts [Execution Policy Settings](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)/ **Example:** `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`.
3. Open `01_Collection.ps1` in a preferred editor/IDE and fill out values for the required variables as outlined above.
4. Run the script in the preferred IDE or it can be run from a PowerShell command prompt by navigating to the directory the file exits in and running the following `.\01_Collection.ps1`.
5. Enter the vCenter username when prompted and press `enter`.
6. Enter vCenter password when prompted and press `enter`.
7. The script should now run, it can take some time depending on the size of the environment.

The output will be an array of CSV files with the name conventions `vms_H4_L3_10.csv (vms_’+
$histLevel+’_”+metricLevel+’_’+$counter+’.csv)`
The script will also produce a csv file with a list of vms including the parameters name, NumCpu, MemoryGB, VMHost, Folder, ResourcePool, Hardware Version, UsedSpaceGB, ProvisionedSPaceGB, CreateDate and moref.
Once complete please upload the outputted csv files as directed by Ascend Cloud Solutions.

# Questionaire
Please fill out and return the below information under the given headings. Please share as much information as possible that is deemed relevant to each section.

## Resource Allocation and Overcommitment
Gather any available information or guidance on current policies around resource overcommit or tiering. The purpose of this is to better equip ourselves when looking at any potential consolidation that may be possible in the cloud environment. If the information is not in hand we can work out current overcommits from the script output files.

1. Do you use any physical or logical compute separation or tiering for different workload categories?
2. If so, what levels of separation are currently in operation for this purpose?
      1. Clusters
      2. Hosts
      3. Resource Pools
      4. vApps
      5. VM Reservations 
3. Label each method used with an overcommit ratio or policy currently in use.
      1. CPU
      2. Memory
4. Do you have any known regularly occurring performance issues or bottlenecks for production workloads?
5. Any other relevant information regarding resource allocation please share it here.

## Dependencies and Constraints Questionnaire
1.In the estate to be migrated, do you have restrictive operating systems, or application licensing models in use that may affect cost at the destination environment?
            1.	SQL
            2.	Oracle
            3.	Licensing Audits that require unrestricted access to hosts etc.
            4.	Per available physical core licensing etc.
2.Do you currently use any of the following
            1.	RDMs
            2.	Directly attached storage
            3.	Shared disks (Quorum)
            4.	Application Clustering (MSCS etc)
3.	In the estate to be migrated, are there any applications or other dependencies on non-virtualised assets that cannot be converted?
4.	Any other relevant information regarding resource constraints or dependencies please share here.

## Network and Security Questionnaire
Gather information related to the network and security of the infrastructure in scope.

1.	What technologies do you use for L3 routing (dynamic routing, etc.)
2.	What technologies do you use for remote sites/users?
    1. IPSec site-to-site (Policy or routed)
    2. SSL VPN
    3. MPLS
    4. Other
3.	Are Load Balancers in use?
      1.	L4 or L7?
      2.	SSL Offloading?
      3.	Any additional features?
4.	Is WAN/OPT in use?
      1.	L2 or L3?
5.	What is being used for firewalling?
6.	Is defense in depth being utilised?
7.	Are there any WAFs deployed?
8.	Are you using IDS/IPS?
9.	What tools are being used for antivirus?
      1.	Agent or agentless?
10.	Do you utilise any CDN (Content Delivery Network)
11.	Any additional service/feature that may be relevant?
12.	If possible, please complete a table of Network and Security assets with a summary of purpose/features similar to the following table.

![Table 2](https://github.com/user-attachments/assets/8ae1d583-ce5f-42cc-b5b7-b78f24cf6416)

Please return the completed information to Ascend Cloud Solutions


    



   
