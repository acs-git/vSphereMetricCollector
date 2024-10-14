## Variables ####
$vcenter = ''
$username = Read-Host "What is your username to login to $vcenter ?" #'administrator@vsphere.local'
$pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($(Read-Host 'What is your password?' -AsSecureString)))| ConvertTo-SecureString -AsPlainText -Force
$OutputDIR = 'C:\Some\Path\'+ $vcenter
$metricLevel = 'L1' ## Options: L1 ,L2, L3
$histLevel = 'H4' ## Options: H1, H2, H3, H4
$maxFileSize = 30MB



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
        
        
        Write-host "Getting stats for $vm... "
        ##  get all vms from the connected vCenter
        $VMServer = Get-VM $VM
    
        if ($VMServer) {
            write-host $VMServer
            write-host $histint
            write-host $stats
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
$credential = New-Object System.Management.Automation.PSCredential($username, $pass)
$vc_conn = connect-viserver $vcenter -Credential $credential -ErrorAction Stop 

## retrieve list of vms
$vms = get-vm -server $vc_conn 

## get metrics for each vm and saves it to CSV
#$counter = 1
#$filename = $OutputDIR+'\vms_'+ $histLevel+'_'+$metricLevel+'_'+$counter+'.csv'
write-host "collecting metrics with MetricLevel: $metricLevel and Histstat: $histLevel "
foreach($vm in $vms){
        $filename = $OutputDIR+'\vm_'+$($vm.name)+ '_'+ $histLevel+'_'+$metricLevel+'.csv'  
        ## run the Get-VMMetrics function 
        Get-VMMetrics -VM $($vm.name) -MetricLevel $metricLevel -histLevel $histLevel | Export-Csv -Path $filename -NoTypeInformation -Append
        ## control to regulate individual file size
          if((get-item $filename).Length -gt $maxFileSize){
            $counter += 1  
            $filename = $OutputDIR+'\vms_'+ $histLevel+'_'+$metricLevel+'_'+$counter+'.csv'
            write-host "creating to file $filename"
          }
}

## Filter for required VM data and export as CSV to output diirectory
$params = @('name',
            'NumCpu',
            'MemoryGB',
            'VMHost',
            'Folder',
            'ResourcePool',
            'HardwareVersion',
            'UsedSpaceGB',
            'ProvisionedSpaceGB',
            'CreateDate',
            @{n='moref'; e={$_.extensionData.moref.value}}
            )

            ## export vm data to csv
$vms | select $params | Export-Csv -Path "$OutputDIR\listVMs.csv" -NoTypeInformation

