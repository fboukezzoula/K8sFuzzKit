
## _K8sFuzzKit_ : a new tool to deploy a full Kubernetes Cluster with embed external tools in Hyper-V in only one click !

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/K8sFuzzKitLogo.png)


There are multiple guides on running Kubernetes and there is a lot of solutions to deploy a Kubernetes Cluster On-Premise (Kubespray, Kops, MiniKube, etc ...).

**_K8sFuzzKit_** is a new way to deploy a full Kubernetes Cluster in only **"one mouse click"**.  

## But not only ...
 
+ You will decide the size of your Kubernetes Cluster (how many total nodes ?). **_K8sFuzzKit_** will define for you how many managers and workers nodes the tool will automatically deploy and configure for you.

_Example :_ 
**3** total nodes will be convert to 1 manager node and 2 worker nodes. 
**5** total nodes will be convert to 2 managers nodes and 3 worker nodes. etc ... 

+ **_K8sFuzzKit_** will deploy and configure a full Kubernetes Cluster in **Hyper-V** for you. You have only to define the configuration of each VM (name of the VM, vCPU, RAM) and, the information of your internal virtual switch like the name, the address @IP plage, etc ...  (which will be automatically nat with the nic of the host to be able to go to internet). Your Cluster Kubernetes will always have the latest version of CentOS up to date (yum update), **the latest version of Kubernetes and dependencies (like _kubelet, dockerd, cni_, ...)**
 
+ The full installation and configuration **_Helm and Tiller_**, the cluster-side service, will be automatically done for you ! In a **_secured approach_** ...

+ You can easy activate the installation of an external tools to complete your Kubernetes Cluster installation like an external secret and configuration management service (vault, consul), 
a service mesh (istio, gloo, linkerd), a serverless service/framework (openfaas, kubeless, openwhisk), a CD/CI service (Jenkins-x) and more tools in the next release (Stay tuned !) 
 
+ Your laptop/desktop will be automatically configure to use your Kubernetes Cluster matching your parameters (command kubectl for example) and all the external tools (istioctl, jx the CLI of Jenkins-X, etc ...). Cool, isn't it ?

+ A browser will be automatically open at the end of the Kubernetes Cluster deployment and you have only to **paste** the authentication token (RBAC) which have been automatically generated and copy to the clipboard for you ! Cool, isn't it ?


To perform all this **_K8sFuzzKit_** configuration and tasks, you have only to update a json file (**_K8sFuzzKit.json_**) and execute the Powershell Script called **_Install-K8sFuzzKit.ps1_**. THAT'S ALL !


## _K8sFuzzKit_ - Setup requirements

+ Hyper-V installed 

``` 
Install-WindowsFeature -Name Hyper-V -ComputerName <computer_name> -IncludeManagementTools -Restart  
``` 

+ Severals tools installed on your laptop/desktop

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install vagrant --version 2.0.2
vagrant plugin install vagrant-reload
choco install kubernetes-cli
choco install kubernetes-helm
```

## _K8sFuzzKit_ - Configure your Kubernetes Cluster and external tools by editing the **_K8sFuzzKit.json_** file

_Edit this json file_ :
+ **hyper-v** node : define the configuration of each VM machine (vCPU, RAM, root name of your VM in Hyper-V, name of the vSwitch, the Subnet Mask and the @IP of the first node in your Kubernetes Cluster) ;

+ **vagrant** node : each VM machine in Hyper-V will mount a CIFS/SMB Share with the host (your laptop/desktop). You have to define a Windows account (in preference an Administrator account but not mandatory. The Windows account have to reach a folder called **_shared_** which will create on the root folder) ;

+ **kubernetes** node : define the total of nodes you want for your Kubernetes Cluster, the intra-network pod type and the CIDR network (the **_K8sFuzzKit_** support only Flannel type on this actual version)

+ **external-tools** node : true = deploy, false = bypass (notice that the dictionary of services will grow and enable in the next version of the tool)

``` 
{
    "K8sFuzzKit": {
        "debug": false,
        "hyper-v": {
            "K8sFuzzKit_VM_CPU": 2,
            "K8sFuzzKit_VM_MEM": 3072,
            "K8sFuzzKit_VM_NAME": "K8sFuzzKit",
            "K8sFuzzKit_VM_VSWITCH": "internal_vSwitch_K8sFuzzKit",
            "K8sFuzzKit_VM_BASE_SUBNET": "10.1.100.",
            "K8sFuzzKit_VM_BASE_IPADDRESS": "10.1.100.200"
        },
        "vagrant": {
            "K8sFuzzKit_OS_IMAGE": "centos/7",
            "K8sFuzzKit_SMB_USERNAME": "vagrantsmb",
            "K8sFuzzKit_SMB_PASSWORD": "24K8sKit09!1",
            "K8sFuzzKit_VM_SSH_PASSWORD": "#K8sFuzzKit#"
        },
        "kubernetes": { 
            "number-nodes-cluster": 3,
            "dns-cluster-add-on" : true,
            "kubernetes-tls" : true,
            "pod-network-add-on" : {
                    "network-type": "Flannel",
                    "network-CIDR": "10.244.0.0/16"
            }
         },
        "external-tools": {
            "vault": false,
            "consul": false,
            "private-registry": false,
            "jenkins-x": true,
            "services-kubernetes-add-one": {
                "service-mesh" : {
                    "istio": true,
		    "gloo": false,
                    "linkerd": false                    
                },
                "serverless" : {
                    "openfaas": false,
                    "kubeless": false,
                    "openwhisk": false
                } 
            }
        }
    }   
}

``` 

## _K8sFuzzKit_ - Run the Powershell script called _Install-K8sFuzzKit.ps1_

+ Hyper-V result after the deployment of **_K8sFuzzKit_** tool and according the **_K8sFuzzKit.json_** configuration :

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/hyperv.png)

+ You can paste the **Kubernetes Dashboard Token** (this token is write in a file called shared\token_dashboard.log and his content is automatically copy to the clipboard for you) :

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/kubernetes_dashboard-token.png)

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/kubernetes_dashboard.png)

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/kubernetes_dashboard_pods.png)

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/commande.png)

![ScreenShot](https://github.com/fboukezzoula/K8sFuzzKit/blob/master/resources/helm_command.png)


## _K8sFuzzKit_ - Feedback and Pull Requests are of course welcome !
If you have some improvements, bug fixes, some new tricks, just post a new PR. 
If you have questions or issues, open an issue for discussion.
