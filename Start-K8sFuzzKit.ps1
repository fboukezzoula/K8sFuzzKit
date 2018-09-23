$global:ProvisioningJsonFile = Get-Content ".\K8sFuzzKit.json" 

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

vagrant up

Get-Job | Remove-Job

$Job = Start-Job -Name "KubectlProxy" -Scriptblock {kubectl proxy}
Start-Sleep -Seconds 3

$bearer_token_dashboard = ".\shared\bearer_token_dashboard.log"
" "
"The below token of the admin-user has been paste in the clipboard - You can paste it in the Dashboard !"
" "
$token = (Select-String -Path $bearer_token_dashboard   -pattern "token:").ToString()
$token
$token.Split(":").Split(" ")[-1] | Out-File -FilePath ".\shared\token_dashboard.log"
Get-Content ".\shared\token_dashboard.log" | clip

Start-Process "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
