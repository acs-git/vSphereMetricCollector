## Variables ####
$inputValues = Get-Content -Path 'collection_input.json' | ConvertFrom-Json
$vcenter = $inputValues.vcenter
$username = $inputValues.username 
$pass = ConvertTo-SecureString $inputValues.Password-ErrorAction Stop
#$pass = ConvertTo-SecureString -String ($inputValues.pass) -AsPlainText -Force
$OutputDIR = $inputValues.OutputDIR+'\VCenter-'+ $vcenter
$metricLevel = $inputValues.metricLevel
$histLevel = $inputValues.histLevel
$maxFileSize = $inputValues.maxFileSize

$statsLevel = @{
    "sys.uptime.latest" = 3;
    "net.usage.average" = 2;
    "mem.vmmemctl.average" = 3;
    "mem.usage.average" = 1;
    "mem.swapoutRate.average" = 1;
    "mem.swapinRate.average" = 1;
    "mem.overhead.average" = 2;
    "mem.consumed.average" = 3;
    "disk.used.latest" = 3;
    "disk.usage.average" = 2;
    "disk.unshared.latest" = 3;
    "disk.provisioned.latest" = 3;
    "disk.maxTotalLatency.latest" = 2;
    "cpu.usagemhz.average" = 1;
    "cpu.usage.average" = 2;
    "cpu.ready.summation" = 1
}

### dependencies
if(![bool](Get-InstalledModule -name VMware.PowerCLI -ErrorAction SilentlyContinue)){
    write-host "VMware.PowerCLI not installed...  " -ForegroundColor Red -NoNewline
    write-host "INSTALLING..." -ForegroundColor Green
    Install-Module VMware.PowerCLI -scope CurrentUser -Confirm:$false -ErrorAction Stop -SkipPublisherCheck
}

## create folder to place data ###
New-Item -Path $OutputDIR -ItemType directory -Force -ErrorAction Stop | Out-Null

### statslevel to psobject
$statsLevels = @()
foreach($key in $statsLevel.GetEnumerator()){ $statsLevels += [PSCustomObject]@{ Metric = $key.Key; Value=$key.value}}

##### functions ####
Function Get-VMMetrics {
  <#
        .SYNOPSIS
            Returns Virtual Machine selected metrics using levels input for connected vCenter over a specified collection interval.

        .DESCRIPTION
            By default this cmdlet returns selected metrics using levels variable for all Virtual Machines in a connected vCenter.

        .PARAMETER VM
            The virtual machine that metric data will be collected for.

        .PARAMETER MetricLevel
            An array of virtual machine statistics to be collected for given virtual machine. 
            Three options as marked in stats level array variable, each one cumulatively including more L1, L2, L3

        .PARAMETER HistLevel
            An option to specify the interval to collect the VM metrics over. 
            H1 will collect the last days. 
            H2 the last day and week. 
            H2 the last day, week ad month. 
            and H4 the day, week, month and year

        .EXAMPLE
            
            Get-VMMetrics -VM 'Test VM' -MetricLevel 'cpu.usage.min' -histLevel 'H1'
            
            Description
            -----------
            This command will return the cpu.usage.min metric data for the last day for Test VM
    #> 
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)] [string] $VM,
        [Parameter(Mandatory=$false)][ValidateSet("L1","L2","L3")][String]$metricLevel="L1",
        [Parameter(Mandatory=$false)][ValidateSet("H1","H2","H3","H4")][String]$histLevel="H4"

        #[pscredential] $Credential,

        #[switch] $Bulk

    )
    Begin {
        ## variables or other task that should be executed in preparation for the main tasks
        ##  Get the service instance listings for connected vCenter
        $getview = Get-View ServiceInstance -Server $vc_conn
        ## Retrieve variable for performance manager settings from vCenter
        $perfcounter = Get-View ($getview).Content.PerfManager
        ##  Retrieve Variable for collection interval settings from vCenter - these intervals in seconds will be used for statistics retrieval 
        $histint = $perfcounter.HistoricalInterval
        ## store todays date, to be used  for  statustics retrival 
        $date = Get-Date
        ## decalre array for metric collection
        $Metrics = @()
    }

    Process {
        ## main tasks/loops
        switch ($metricLevel) {
            ### switch for which statistics to collect from those available - l1 being the least metrics and l2 and l3 cumulatively adding 
            "L1" { $stats = ($statsLevels | ? {$_.value -le 1}).metric ; break }
            "L2" { $stats = ($statsLevels | ? {$_.value -le 2}).metric ; break }
            "L3" { $stats = ($statsLevels | ? {$_.value -le 3}).metric ; break }
        }
        switch ($histLevel) {
            ## switch to select which interval level to collect from. H1 will collect the last days, H2 the last day and week, H2 the last day, week ad month, and H4 the day, week, month and year
            "H1" { $h1 = $true ; break }
            "H2" { $h1 = $true; $h2 = $true; break }
            "H3" { $h1 = $true; $h2 = $true; $h3 = $true; break }
            "H4" { $h1 = $true; $h2 = $true; $h3 = $true; $h4 = $true; break }
        }
        
        
        Write-host "Getting stats for $vm... " -ForegroundColor Yellow
        ##  get all vms from the connected vCenter
        $VMServer = Get-VM $VM
    
        if ($VMServer) {
            ## if conditional bases on interval setting input by user. 
            ##As mentioned in loop it is cumulative. 
            ##Each higher setting collects the previous intervals also.
            if($h1){
                ## stats interval 1 collection 
                $histint_1 = $histint|?{$_.key -eq 1}
                ## get selected statistics for VM
                $Metrics_h1 += Get-Stat -Entity $VMServer `
                                -Stat $stats `
                                -Start $($date.AddSeconds(-$histint_1.length)) `
                                -Finish $date `
                                -IntervalSecs $histint_1.SamplingPeriod `
                                -ErrorAction SilentlyContinue
                $Metrics += $Metrics_h1
            }

            if($h2){
                ## stats interval 1 and 2 collection
                $histint_2 = $histint|?{$_.key -eq 2}
                $Metrics_h2 = Get-Stat  -Entity $VMServer `
                                -Stat $stats `
                                -Start $($date.AddSeconds(-($histint_2.length) + $($histint_1.length))) `
                                -Finish $($date.AddSeconds(-$histint_1.length)) `
                                -IntervalSecs $histint_2.SamplingPeriod `
                                -ErrorAction SilentlyContinue
                $Metrics += $Metrics_h2
            }
            
            if($h3){
                ## stats interval 1, 2 , and 3 collection
                $histint_3 = $histint|?{$_.key -eq 3}
                $Metrics_h3 = Get-Stat  -Entity $VMServer `
                                -Stat $stats `
                                -Start $($date.AddSeconds(-($histint_3.length) + $($histint_2.length))) `
                                -Finish $($date.AddSeconds(-$histint_2.length)) `
                                -IntervalSecs $histint_3.SamplingPeriod `
                                -ErrorAction SilentlyContinue
                $Metrics += $Metrics_h3
            }

            if($h4){
                ## stats interval 1, 2, 3, and 4 collection
                $histint_4 = $histint|?{$_.key -eq 4}
                $Metrics_h4 = Get-Stat  -Entity $VMServer `
                                -Stat $stats `
                                -Start $($date.AddSeconds(-($histint_4.length) + $($histint_3.length))) `
                                -Finish $($date.AddSeconds(-$histint_3.length)) `
                                -IntervalSecs $histint_4.SamplingPeriod `
                                -ErrorAction SilentlyContinue
                $Metrics += $Metrics_h4
            }
        }
    }

    End {
        ## end  - return values, write to db, etc
        return $Metrics | Select-Object     @{n='vmId';e={$_.entity.extensiondata.moref.value}},
                                            MetricId,
                                            IntervalSecs,
                                            Timestamp,
                                            Value,
                                            Unit,
                                            Instance
    }
}

## connect vcenter and store credential data
Write-host "Connecting to $vcenter with username $username" -ForegroundColor Yellow
$credential = New-Object System.Management.Automation.PSCredential($username, $pass)
$vc_conn = connect-viserver $vcenter -Credential $credential -ErrorAction Stop 
if ($vc_conn){Write-Host "Connected to $vCenter" -ForegroundColor Green}

## retrieve list of vms
$vms = get-vm -server $vc_conn |?{$_.Name -notlike "vCLS*"}
$hosts = Get-VMHost -server $vc_conn

## get metrics for each vm and saves it to CSV
#$counter = 1
#$filename = $OutputDIR+'\vms_'+ $histLevel+'_'+$metricLevel+'_'+$counter+'.csv'
write-host "collecting metrics with MetricLevel: $metricLevel and Histstat: $histLevel " -ForegroundColor Yellow
foreach($vm in $vms){
    $filename = $OutputDIR+'\vm_'+$($vm.name)+ '_'+ $histLevel+'_'+$metricLevel+'.csv'  
    ## run the Get-VMMetrics function 
    Get-VMMetrics -VM $($vm.name) -MetricLevel $metricLevel -histLevel $histLevel | Export-Csv -Path $filename -NoTypeInformation -Append
    ## control to regulate individual file size
        if((get-item $filename).Length -gt $maxFileSize){
        $counter += 1  
        $filename = $OutputDIR+'\vms_'+ $histLevel+'_'+$metricLevel+'_'+$counter+'.csv'
        write-host "creating to file $filename" -ForegroundColor Green
        }
}

## Filter for required VM data and export as CSV to output diirectory
$date = Get-Date
$vmParams = @('name',
            'NumCpu',
            'MemoryGB',
            'VMHost',
            'Folder',
            'ResourcePool',
            'HardwareVersion',
            @{n='Disks'; e={($_ | Get-HardDisk).count}},
            @{n='UsedSpaceGB'; e={[math]::Round($_.UsedSpaceGB,1)}},
            @{n='ProvisionedSpaceGB'; e={[math]::Round($_.ProvisionedSpaceGB,1)}},
            'CreateDate',
            'PowerState',
            @{n='Guest Family'; e={$_.Guest.OSFullName}},
            @{n='Guest OS'; e={$_.ExtensionData.Guest.GuestFamily}},
            @{n='Tools Status'; e={($_.ExtensionData.Guest.ToolsStatus)}},
            @{n='Guest State'; e={($_.Guest.State)}},
            @{n='Portgroup'; e={($_ | Get-VirtualPortGroup).Name}},
            @{n='PG vlan ID'; e={($_ | Get-VirtualPortGroup).VLanId}},
            @{n='Primary IP'; e={$_.Guest.IPAddress[0]}},
            @{n='Uptime Days'; e={[math]::round(($date - $_.ExtensionData.Runtime.BootTime).TotalDays,1)}},
            @{n='ESXi Host'; e={$_.VMHost.name}},
            @{n='Cluster'; e={($_.VMHost.parent.name -replace '[][]', '')}},
            @{n='moref'; e={$_.extensionData.moref.value}}
            )

$hostParams = @('Name',
                'Version'
                @{n='HostID'; e={($_.ID -replace 'HostSystem-', '')}},
                'Manufacturer',
                'Model',
                'ProcessorType'
                #@{n=''; e={($_.)}},
                @{n='CPU Sockets'; e={($_.ExtensionData.Hardware.cpuinfo.NumCpuPackages)}},
                @{n='CPU Cores'; e={($_.ExtensionData.Hardware.cpuinfo.NumCpuCores)}},
                @{n='CPU Threads'; e={($_.ExtensionData.Hardware.cpuinfo.NumCpuThreads)}},
                @{n='CPU Speed GHz'; e={[math]::round($_.ExtensionData.Hardware.cpuinfo.HZ / 1000000000,2)}},
                @{n='CPU Cycles GHz'; e={[math]::round($_.CPUTotalMhz / 1000,2)}},
                @{n='CPU Usage GHz'; e={[math]::round($_.CpuUsageMhz / 1000,2)}},
                @{n='Memory GB'; e={[math]::round($_.MemoryTotalGB)}},
                @{n='Memory Usage GB'; e={[math]::round($_.MemoryUsageGB)}},
                @{n='Hyperthreading'; e={($_.HyperthreadingActive)}},
                @{n='MAX EVC'; e={($_.MaxEVCMode)}},
                @{n='VM Count'; e={($_.ExtensionData.Vm.Count)}},
                @{n='Current EVC'; e={($_.ExtensionData.Summary.CurrentEVCModeKey)}},
                @{n='Cluster'; e={($_.parent.name -replace '[][]', '')}}
                @{n='Datastores'; e={((($_ | Get-Datastore).Name | sort -Unique) -join ' || ') }},
                #@{n='Datastores 2'; e={(($_ | Get-Datastore).datastores.name | sort -Unique) -join ' | '}}
                @{n='Portgroups'; e={(Get-VirtualPortGroup -VMhost $_).Name}}
            )

$tesParams =   @(
                @{n='CPU Speed'; e={[math]::round($_.ExtensionData.Hardware.cpuinfo.HZ / 1000000000,2)}}
                )

## export vm data to csv
write-host "Exporting VM Data to CSV" -ForegroundColor Yellow
$vms | select $vmParams | Export-Csv -Path "$OutputDIR\listVMs.csv" -NoTypeInformation
write-host "VM Data Exported to $OutputDIR\listVMs.csv" -ForegroundColor Green

write-host "Exporting Host Data to CSV" -ForegroundColor Yellow
$hosts | select $hostParams #| Export-Csv -Path "$OutputDIR\listHosts.csv" -NoTypeInformation
write-host "VM Data Exported to $OutputDIR\HostInfo.csv" -ForegroundColor Green

Exit

