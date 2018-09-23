Function global:K8sFuzzKit_Set_All_Variables_ClusterKubernetes {

    param ($ProvisioningJsonFile)

$K8sFuzzKit_ProvisioningJsonFile = @"
$ProvisioningJsonFile
"@

    $K8sFuzzKit_parameter = $K8sFuzzKit_ProvisioningJsonFile | ConvertFrom-Json

    # Debug switch
    # $env:K8sFuzzKit_DEBUG = $K8sFuzzKit_parameter.K8sFuzzKit.'debug'

    # Parameters for Hyper-V
    $env:K8sFuzzKit_VM_CPU = $K8sFuzzKit_parameter.K8sFuzzKit.'hyper-v'.K8sFuzzKit_VM_CPU
    $env:K8sFuzzKit_VM_MEM = $K8sFuzzKit_parameter.K8sFuzzKit.'hyper-v'.K8sFuzzKit_VM_MEM
    $env:K8sFuzzKit_VM_VSWITCH = $K8sFuzzKit_parameter.K8sFuzzKit.'hyper-v'.K8sFuzzKit_VM_VSWITCH
    $env:K8sFuzzKit_VM_NAME = $K8sFuzzKit_parameter.K8sFuzzKit.'hyper-v'.K8sFuzzKit_VM_NAME
    $env:K8sFuzzKit_VM_BASE_SUBNET = $K8sFuzzKit_parameter.K8sFuzzKit.'hyper-v'.K8sFuzzKit_VM_BASE_SUBNET
    $env:K8sFuzzKit_VM_BASE_IPADDRESS = $K8sFuzzKit_parameter.K8sFuzzKit.'hyper-v'.K8sFuzzKit_VM_BASE_IPADDRESS
    
    # Parameters for Vagrant 
    $env:K8sFuzzKit_SMB_USERNAME = $K8sFuzzKit_parameter.K8sFuzzKit.vagrant.K8sFuzzKit_SMB_USERNAME
    $env:K8sFuzzKit_SMB_PASSWORD = $K8sFuzzKit_parameter.K8sFuzzKit.vagrant.K8sFuzzKit_SMB_PASSWORD
    $env:K8sFuzzKit_VM_SSH_PASSWORD = $K8sFuzzKit_parameter.K8sFuzzKit.vagrant.K8sFuzzKit_VM_SSH_PASSWORD
    $env:K8sFuzzKit_VM_OS_IMAGE = $K8sFuzzKit_parameter.K8sFuzzKit.vagrant.K8sFuzzKit_OS_IMAGE

    # Parameters for kubernetes
    $env:K8sFuzzKit_TOTAL_CLUSTER_NODES = $K8sFuzzKit_parameter.K8sFuzzKit.kubernetes.'number-nodes-cluster'
    $env:K8sFuzzKit_DNS_CLUSTER = $K8sFuzzKit_parameter.K8sFuzzKit.kubernetes.'dns-cluster-add-on'
    $env:K8sFuzzKit_CLUSTER_TLS = $K8sFuzzKit_parameter.K8sFuzzKit.kubernetes.'kubernetes-tls'

    $env:K8sFuzzKit_POD_NETWORK_TYPE = $K8sFuzzKit_parameter.K8sFuzzKit.kubernetes.'pod-network-add-on'.'network-type'
    $env:K8sFuzzKit_POD_NETWORK_CIDR = $K8sFuzzKit_parameter.K8sFuzzKit.kubernetes.'pod-network-add-on'.'network-CIDR'

    # Parameters for external tools such as vault, consul, oss ...
    $env:K8sFuzzKit_EXTERNAL_VAULT = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.vault
    $env:K8sFuzzKit_EXTERNAL_CONSUL = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.consul

    $env:K8sFuzzKit_EXTERNAL_PRIVATE_REGISTRY = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'private-registry'
    $env:K8sFuzzKit_EXTERNAL_JENKINS_X = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'jenkins-x'

    $env:K8sFuzzKit_EXTERNAL_SERVICE_MESH_ISTIO = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'services-kubernetes-add-one'.'service-mesh'.istio
    $env:K8sFuzzKit_EXTERNAL_SERVICE_MESH_GLOO = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'services-kubernetes-add-one'.'service-mesh'.gloo
    $env:K8sFuzzKit_EXTERNAL_SERVICE_MESH_LINKERD = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'services-kubernetes-add-one'.'service-mesh'.linkerd
    
    
    $env:K8sFuzzKit_EXTERNAL_SERVERLESS_OPENFAAS = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'services-kubernetes-add-one'.serverless.openfaas
    $env:K8sFuzzKit_EXTERNAL_SERVERLESS_KUBELESS  = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'services-kubernetes-add-one'.serverless.kubeless
    $env:K8sFuzzKit_EXTERNAL_SERVERLESS_KUBELESS = $K8sFuzzKit_parameter.K8sFuzzKit.'external-tools'.'services-kubernetes-add-one'.serverless.openwhisk

    $env:Total_VM_K8sCluster = [convert]::ToInt32($env:K8sFuzzKit_TOTAL_CLUSTER_NODES)

    $LastOctetAdress = $env:K8sFuzzKit_VM_BASE_IPADDRESS.Split('.')
    $global:NextIP = [int]($LastOctetAdress[-1]) 
    
    $env:BASE_IPADDRESS = $global:NextIP-1

    switch ($env:Total_VM_K8sCluster ) {

        {($env:Total_VM_K8sCluster  -lt 3)} 
            {
                Write-Host " ";Write-host "For creating a Kubernetes cluster with this K8sFuzzKit tool, you need miminum 3 VMs. Please choose a correct number of Servers and retry ..."  ;
                Write-Host " "; break
            } 

        # If total-number-nodes-cluster (>= 3  and < 5) (=3,4)
        {(($env:Total_VM_K8sCluster  -ge 3) -and ($env:Total_VM_K8sCluster  -lt 5))} 

            {
                $env:K8sFuzzKit_NbrK8sManager = $env:K8sFuzzKit_NbrConsulServer = 1
                $env:K8sFuzzKit_NbrK8sWorker  = $env:K8sFuzzKit_NbrConsulAgent  = ($env:Total_VM_K8sCluster -1)
            }

        # If total-number-nodes-cluster (>= 5 and < 8)
        {(($env:Total_VM_K8sCluster  -ge 5) -and ($env:Total_VM_K8sCluster  -lt 8))} 
            {
                $env:K8sFuzzKit_NbrK8sManager = $global:K8sFuzzKit_NbrConsulServer = 2
                $env:K8sFuzzKit_NbrK8sWorker    = $global:K8sFuzzKit_NbrConsulAgent  = ($env:Total_VM_K8sCluster -2)
            }

        # If total-number-nodes-cluster (>= 8) 
        {($env:Total_VM_K8sCluster  -ge 8)} 
            {
                $env:K8sFuzzKit_NbrK8sManager = $global:K8sFuzzKit_NbrConsulServer = 3
                $env:K8sFuzzKit_NbrK8sWorker  = $global:K8sFuzzKit_NbrConsulAgent  = ($env:Total_VM_K8sCluster -3)
            }
     }
}

Function global:K8sFuzzKit_Servers_Configuration_ClusterKubernetes {
    param ($NbrK8sManager,$NbrK8sWorker)

    if ($NbrK8sManager -gt 1) {
        $NbrK8sManagernodes = "@                      $NbrK8sManager K8s Managers Nodes                                    @"
    }

    if ($NbrK8sManager -eq 1) {
        $NbrK8sManagernodes = "@                      $NbrK8sManager K8s Manager Node                                        @"
    }

$myK8sCluster = @" 

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@              The configuration of your Kubernetes Cluster will be :            @
@                                                                                @
$NbrK8sManagernodes
@                      $NbrK8sWorker K8s Workers Nodes                                       @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

"@

$myK8sCluster 

    
}

Function global:K8sFuzzKit_CreateServerNode {

    param($ServersInCluster,$K8sHostName,$NextIP,$NbrK8sManager,$NbrK8sWorker)
    
    $TotalServers = 1

    Do
    {

    ### Create the K8sManager(s)
    $TotalK8sManager = 1 
    $LastOctetAdress = $env:K8sFuzzKit_VM_BASE_IPADDRESS.Split('.')

        Do
        {
            $NextIP = [int]($LastOctetAdress[-1]) + $TotalK8sManager
            $Base = $NextIP-1

            $env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE = "$env:K8sFuzzKit_VM_BASE_SUBNET$Base"
            $env:K8sFuzzKit_HOSTNAME_TO_CREATE = $K8sHostName+"-Manager-Node0"+$TotalK8sManager
           
            " " 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
            $Message = "Starting Creation K8sManager   : "+$env:K8sFuzzKit_HOSTNAME_TO_CREATE+ "   [@IP :" +$env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE +"]"   
            $Message 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
            " " 

            $HostsFile.add("$env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE $env:K8sFuzzKit_HOSTNAME_TO_CREATE")
            $K8sFuzzKitMasterNodes.add("$env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE $env:K8sFuzzKit_HOSTNAME_TO_CREATE")
  
            $TotalK8sManager++
            $TotalServers++
 
        } While ($TotalK8sManager -le $NbrK8sManager)

    ### Create the K8sNode(s) 
    $TotalK8sNodes  = 1 
        Do
        {
            $NextIP = [int]($LastOctetAdress[-1]) + $TotalServers
            $Base = $NextIP-1
           
            $env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE = "$env:K8sFuzzKit_VM_BASE_SUBNET$Base"
            $env:K8sFuzzKit_HOSTNAME_TO_CREATE = $K8sHostName+"-Worker-Node0"+$TotalK8sNodes

            " "
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" 
            $Message = "Starting Creation K8sWorker    : " +$env:K8sFuzzKit_HOSTNAME_TO_CREATE+ "    [@IP :" +$env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE+"]" 
            $Message
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" 
            " " 

            $HostsFile.add("$env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE $env:K8sFuzzKit_HOSTNAME_TO_CREATE")
            $K8sFuzzKitWorkerNodes.add("$env:K8sFuzzKit_IPADDRESS_CLUSTER_NODE_TO_CREATE $env:K8sFuzzKit_HOSTNAME_TO_CREATE")

            $TotalK8sNodes++
            $TotalServers++

        } While ($TotalK8sNodes -le $NbrK8sWorker)

    } while ($TotalServers -le $ServersInCluster)

    

}

# Function for creating a file with Unix format under Windows
function global:K8sFuzzKit_OutUnix
{
    param ([string] $Path)
   
    
    begin 
    {
        $streamWriter = New-Object System.IO.StreamWriter("$Path", $false)
    }
    
    process
    {
        $streamWriter.Write(($_ | Out-String).Replace("`r`n","`n"))
    }
    end
    {
        $streamWriter.Flush()
        $streamWriter.Close()
    }
}

Function global:K8sFuzzKit_Prepare_HostsFile {

    param ($HostFileName)

    if (Test-Path $RootPathSharedSMB\$HostFileName) {
        Remove-Item -Recurse -Force $RootPathSharedSMB\$HostFileName
    } 

    $Location = Get-Location 
        
    $HostsFile | K8sFuzzKit_OutUnix -Path "$Location\$RootPathSharedSMB\$HostFileName"
    $HostsFile | Out-File -FilePath $RootPathSharedSMB\hosts_for_local_windows -Append -Force


    " "
    " " | K8sFuzzKit_OutUnix -Path "$Location\$RootPathSharedSMB\pod_network_cidr.log"
    " " | K8sFuzzKit_OutUnix -Path "$Location\$RootPathSharedSMB\helm_tiller.log"
    " " | K8sFuzzKit_OutUnix -Path "$Location\$RootPathSharedSMB\service_account_and_clusterrolebinding_dashboard.log"
    " "
}

Function global:K8sFuzzKit_CopyToVM_HostsFile {

    $Location = Get-Location
    $usernameSSH = "root"
    $passwordSSH = ConvertTo-SecureString "vagrant" -AsPlainText -Force 
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameSSH, $passwordSSH

    $Command = "cat /shared/hosts >> /etc/hosts"

    foreach ($element in $global:HostsFile) {

        $IPNode = $element.Split(" ")[-2]
        $VMName = $element.Split(" ")[-1]
        "@@@@@ Create a new SSHSession on $VMName Server"
		Start-Sleep -Milliseconds 500
        New-SSHSession -ComputerName $IPNode -Credential $cred -Force
        $SessionID = (Get-SSHSession).SessionId

        "@@@@@ Copy generated hosts file, base on your configuration, to $VMName Server"
        Invoke-SSHCommand -Command $Command -SessionId $SessionID

        "@@@@@ Remove the SSHSession on $VMName Server"
        Remove-SSHSession $SessionID
        " "	
		
    }
}

Function global:K8sFuzzKit_Create_ClusterKubernetes {

    $Location = Get-Location
    $usernameSSH = "root"
    $passwordSSH = ConvertTo-SecureString "vagrant" -AsPlainText -Force 
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameSSH, $passwordSSH

    $Command_PodNetworkCIDR = "kubeadm init --pod-network-cidr=$env:K8sFuzzKit_POD_NETWORK_CIDR >> /shared/pod_network_cidr.log 2>&1"
    $Command_StartUsingKubernetesCluster = "mkdir -p `$HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf `$HOME/.kube/config && sudo chown `$(id -u):`$(id -g) `$HOME/.kube/config && mkdir /shared/.kube && sudo cp -i /etc/kubernetes/admin.conf /shared/.kube/config"
    $Command_InstallFlannelNetwork = "curl https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml > /shared/kube-flannel.yml && kubectl apply -f /shared/kube-flannel.yml >> /shared/kube-flannel.log 2>&1"
    $Command_KubeAdmJoin = "kubeadm token create --print-join-command >> /shared/join.command"
    $Command_JoinWorkerToKubernetesCluster = "chmod +x /shared/join.command && /shared/join.command >> /shared/join_workers_to_cluster.log 2>&1" 


    $IPMasterNode = $K8sFuzzKitMasterNodes[0].Split(" ")[-2]
    $VMMasterName = $K8sFuzzKitMasterNodes[0].Split(" ")[-1]

    "@@@@@ Create a new SSHSession on $VMMasterName Server"
	Start-Sleep -Milliseconds 500
    New-SSHSession -ComputerName $IPMasterNode -Credential $cred -Force
    $SessionID = (Get-SSHSession).SessionId

    " "
    "@@@@@ We are using the Flannel network for this Kubernetes Cluster."
    "@@@@@ To make the flannel to working properly, we need to specify the network CIDR while configuring the cluster ... Please Wait ..."
    Invoke-SSHCommand -Command $Command_PodNetworkCIDR -SessionId $SessionID -TimeOut 600     

    Do
    {
        $SearchString = Select-String -Path .\shared\pod_network_cidr.log -Pattern "kubeadm join"

        "Processing ... It will take few minutes to complete the installation ... Please Wait ..."  
        Start-Sleep -Seconds 5
  
    } While ($SearchString.Count -eq 0)

    "@@@@@ The Log output is : "
    Get-Content .\shared\pod_network_cidr.log
    " "

    Invoke-SSHCommand -Command $Command_StartUsingKubernetesCluster -SessionId $SessionID

    "@@@@@ Installing the Flannel network. Please wait."
    Invoke-SSHCommand -Command $Command_InstallFlannelNetwork -SessionId $SessionID -TimeOut 600

    "@@@@@ The Log output is : "
    Get-Content .\shared\kube-flannel.log
    " "

    "@@@@@ Export the kubeadm join information to a file."
    Invoke-SSHCommand -Command $Command_KubeAdmJoin -SessionId $SessionID -TimeOut 600

    "@@@@@ The below command from the master server to retrieve the join information is : "
    Get-Content .\shared\join.command
    " "    

    foreach ($worker in $global:K8sFuzzKitWorkerNodes) {

        $IPWorkerNode = $worker.Split(" ")[-2]
        $VMWorkerName = $worker.Split(" ")[-1]
        "@@@@@ Create a new SSHSession on $VMWorkerName Server"
        New-SSHSession -ComputerName $IPWorkerNode -Credential $cred -Force
        $SessionWorkerID = (Get-SSHSession).SessionID

        "@@@@@ Join $VMWorkerName Server to the Kubernetes Cluster ... Please Wait ..."
        Invoke-SSHCommand -Command $Command_JoinWorkerToKubernetesCluster -SessionID $SessionWorkerID -TimeOut 600

        "@@@@@ Remove the SSHSession on $VMWorkerName Server"
        Remove-SSHSession $SessionWorkerID
        " "
				
    }

    "@@@@@ The Log output is : "
    Get-Content .\shared\join_workers_to_cluster.log
    " " 
 
    "@@@@@ Remove the SSHSession on $VMMasterName Server"
    Remove-SSHSession $SessionID
    " " 
	
}


Function global:K8sFuzzKit_InstallHelmAndTiller {

    $Location = Get-Location
    $usernameSSH = "root"
    $passwordSSH = ConvertTo-SecureString "vagrant" -AsPlainText -Force 
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameSSH, $passwordSSH

    $IPMasterNode = $K8sFuzzKitMasterNodes[0].Split(" ")[-2]
    $VMMasterName = $K8sFuzzKitMasterNodes[0].Split(" ")[-1]

    $Command_InstallHelmAndTiller = "curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > /shared/get_helm.sh && chmod 700 /shared/get_helm.sh && /shared/get_helm.sh && helm init >> /shared/helm_tiller.log 2>&1 && kubectl create serviceaccount --namespace kube-system tiller >> /shared/helm_tiller.log 2>&1 && kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller >> /shared/helm_tiller.log 2>&1 && kubectl patch deploy --namespace kube-system tiller-deploy -p '{""spec"":{""template"":{""spec"":{""serviceAccount"":""tiller""}}}}' >> /shared/helm_tiller.log 2>&1 && helm init --service-account tiller --upgrade >> /shared/helm_tiller.log 2>&1"

    "@@@@@ Create a new SSHSession on $VMMasterName Server"
	Start-Sleep -Milliseconds 500
    New-SSHSession -ComputerName $IPMasterNode -Credential $cred -Force
    $SessionID = (Get-SSHSession).SessionId

    Invoke-SSHCommand -Command $Command_InstallHelmAndTiller -SessionId $SessionID -TimeOut 600
    "@@@@@ Enable Helm in the Kubernetes K8sFuzzKit Cluster."

    Do
    {
        $SearchString = Select-String -Path .\shared\helm_tiller.log -Pattern "deployment.extensions/tiller-deploy patched"

        "Processing ... It will take few seconds to complete the installation ... Please Wait ..."  
        Start-Sleep -Seconds 5
  
    } While ($SearchString.Count -eq 0)

    " "
    Get-Content .\shared\helm_tiller.log
    " " 
 
    "@@@@@ Remove the SSHSession on $VMMasterName Server"
    Remove-SSHSession $SessionID
    " "

}


Function global:K8sFuzzKit_KubeConfig  {

    $GetDate = Get-Date -Format yyyyMMdd_HHmmss

    $SourceKubeConfig = ".\shared\.kube"
    $DestinationKubeConfig = "$env:USERPROFILE\.kube"
    if (Test-Path $DestinationKubeConfig) { 
        try {
            Rename-Item -Path "$DestinationKubeConfig" -NewName ".kube_$GetDate" -ErrorAction Stop
            Write-Verbose "Backup your .kube folder in .kube_$GetDate folder." -Verbose
            Copy-Item $SourceKubeConfig -Destination $DestinationKubeConfig -Recurse -Force
        }catch{
            Write-Warning "Something went wrong while backuping your .kube folder in .kube_$GetDate folder."
        }
     } else {
        Copy-Item $SourceKubeConfig -Destination $DestinationKubeConfig -Recurse -Force 
  
    }
}





