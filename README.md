
## K8sFuzzKit : a new tool to deploy a full Kubernetes Cluster with embed external tools in Hyper-V in only one click !

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
 
+ A browser will be automatically open at the end of the Kubernetes Cluster deployment and you have only to **paste** the authentication token (RBAC) which have been automatically generated and copy to the clipboard for you ! 


## Feedback and Pull Requests are of course welcome !
If you have some improvements, bug fixes, some new tricks, just post a new PR. 
If you have questions or issues, open an issue for discussion.
