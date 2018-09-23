Set-StrictMode -version 3
$ErrorActionPreference = "Stop"

<# 
K8sFuzzKit v1.0.0
Author : Fouzi BOUKEZZOULA
Twitter, Facebook : @fboukezzoula

https://github.com/fboukezzoula/K8sFuzzKit

@September 2018
------------------------------------------------------------------------------------
Execution PS Security has to be set like for example : 
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force 
or 
Set-ExecutionPolicy Unrestricted
#>

Clear-Host;

$global:RootPathVagrant = ".vagrant"
$global:RootPathSharedSMB = "shared"
$global:VagrantfilePath = ".\K8sFuzzKit-Vagrant\Vagrantfile"
$global:HostFileName = "hosts"

$global:HostsFile = New-Object System.Collections.Generic.List[System.Object]
$global:K8sFuzzKitMasterNodes = New-Object System.Collections.Generic.List[System.Object]
$global:K8sFuzzKitWorkerNodes = New-Object System.Collections.Generic.List[System.Object]

$global:ProvisioningJsonFile = Get-Content "K8sFuzzKit.json" 

Import-Module .\K8sFuzzKit-Modules\K8sFuzzKit-HyperV -Force 
Import-Module .\K8sFuzzKit-Modules\K8sFuzzKit-Kubernetes -Force 
Import-Module .\K8sFuzzKit-Modules\K8sFuzzKit-ExternalTools -Force 
Import-Module .\K8sFuzzKit-Modules\K8sFuzzKit-Vagrant -Force

Import-Module -Name Posh-SSH -Force 

#_________________________________________________________________________________

if (Test-Path $RootPathVagrant) {
    Remove-Item -Recurse -Force $RootPathVagrant
    " "
}

if (Test-Path $RootPathSharedSMB) {
    Remove-Item -Recurse -Force $RootPathSharedSMB
    New-Item -Path $RootPathSharedSMB -ItemType Directory | Out-Null
    " "
} else {
    New-Item -Path $RootPathSharedSMB -ItemType Directory | Out-Null
    " "
}

################
# MAIN PROGRAM #
################

K8sFuzzKit_Set_All_Variables_ClusterKubernetes $ProvisioningJsonFile

if ($env:K8sFuzzKit_DEBUG) { Set-PSDebug -Trace 1 }

K8sFuzzKit_Servers_Configuration_ClusterKubernetes $env:K8sFuzzKit_NbrK8sManager $env:K8sFuzzKit_NbrK8sWorker

K8sFuzzKit_CreateServerNode $env:Total_VM_K8sCluster $env:K8sFuzzKit_VM_NAME $NextIP $env:K8sFuzzKit_NbrK8sManager $env:K8sFuzzKit_NbrK8sWorker

K8sFuzzKit_Create_vSwitch $env:K8sFuzzKit_VM_VSWITCH $true

K8sFuzzKit_CopyAndPrepare_Vagrantfile $global:VagrantfilePath

K8sFuzzKit_Prepare_HostsFile $global:HostFileName

K8sFuzzKit_CommandVagrant_Valide_Up_Reload

K8sFuzzKit_CopyToVM_HostsFile

K8sFuzzKit_Create_ClusterKubernetes

K8sFuzzKit_InstallHelmAndTiller

K8sFuzzKit_KubeConfig

if ($env:K8sFuzzKit_EXTERNAL_SERVICE_MESH_ISTIO) { K8sFuzzKit_InstallIstioWithHelmAndTiller }
if ($env:K8sFuzzKit_EXTERNAL_JENKINS_X)          { K8sFuzzKit_InstallJenkinsXCLI            }

K8sFuzzKit_InstallDashboard

K8sFuzzKit_StartKubectlProxy_Dashboard




