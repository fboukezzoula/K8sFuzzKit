Function global:K8sFuzzKit_InstallIstioWithHelmAndTiller {

    $Location = Get-Location
    $usernameSSH = "root"
    $passwordSSH = ConvertTo-SecureString "vagrant" -AsPlainText -Force 
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameSSH, $passwordSSH

    $IPMasterNode = $K8sFuzzKitMasterNodes[0].Split(" ")[-2]
    $VMMasterName = $K8sFuzzKitMasterNodes[0].Split(" ")[-1]

$Command_InstallIstioWithHelmAndTiller = @"
curl -sSL https://git.io/getLatestIstio | sh -
cp istio-*/bin/istioctl /usr/bin/istioctl
chmod +x /usr/bin/istioctl
helm install istio-*/install/kubernetes/helm/istio --name istio --namespace istio-system > /shared/istio_chart_helm.log
"@

    $Command_InstallIstioWithHelmAndTiller | K8sFuzzKit_OutUnix -Path $Location\shared\IstioWithHelmAndTiller.sh

    $Command_InstallIstioWithHelmAndTillerExecute = "chmod 700 /shared/IstioWithHelmAndTiller.sh && /shared/IstioWithHelmAndTiller.sh"

    " "
    "@@@@@ Create a new SSHSession on $VMMasterName Server"
    New-SSHSession -ComputerName $IPMasterNode -Credential $cred -Force
    $SessionID = (Get-SSHSession).SessionId

    $TestTillerDeployUP = "kubectl get pods --namespace kube-system"    

    Do
    {
        $Content = Invoke-Expression $TestTillerDeployUP
        
        "Wait for the tiller-deploy pod is up and running on the cluster Kubernetes before installing istio with helm chart ... Please Wait ..."  
        Start-Sleep -Seconds 15
  
    } While (!($Content | select-string -pattern "tiller-deploy" | select-string -pattern "1/1"))


    "@@@@@ Installating and configuring Istio with Helm Chart in the K8sFuzzKit Cluster."   
    Invoke-SSHCommand -Command $Command_InstallIstioWithHelmAndTillerExecute -SessionId $SessionID -TimeOut 600

    Do
    {
        $SearchString = Select-String -Path .\shared\istio_chart_helm.log -Pattern "kubernetesenv"

        "Processing ... It will take few seconds to complete the installation ... Please Wait ..."  
        Start-Sleep -Seconds 5
  
    } While ($SearchString.Count -eq 0)

    " "
    Get-Content .\shared\istio_chart_helm.log
    " " 
 
    "@@@@@ Remove the SSHSession on $VMMasterName Server"
    Remove-SSHSession $SessionID
    " " 
  
}

Function global:K8sFuzzKit_InstallJenkinsXCLI  {

    if (Test-Path .\shared\jenkins-x) {
        Remove-Item -Recurse -Force .\shared\jenkins-x
        New-Item -Path .\shared\jenkins-x -ItemType Directory | Out-Null
        " "
    } else {
        New-Item -Path .\shared\jenkins-x -ItemType Directory | Out-Null
        " "
    }
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12

    "@@@@@ Install the Jenkins-X CLI binary on localhost to interact with the cluster kubernetes ... Please Wait ..."

    Invoke-WebRequest -Uri "https://github.com/jenkins-x/jx/releases/download/v1.3.272/jx-windows-amd64.zip" -OutFile ".\shared\jenkins-x\jx.zip"
    Expand-Archive -Path ".\shared\jenkins-x\jx.zip" -DestinationPath ".\shared\jenkins-x\" ; Remove-Item -Path ".\shared\jenkins-x\jx.zip" -Force
    Rename-Item -Path ".\shared\jenkins-x\jx-windows-amd64.exe" -NewName "jx.exe" ; $env:Path += ";.\shared\jenkins-x\"

    $TestCommandJenkinsXCLI = "jx.exe"
    " "
    "@@@@@ You can now use Jenkins-X CLI to deploy apps in the cluster Kubernetes. Help of the jx commands and options CLI :"
    " "
    Invoke-Expression $TestCommandJenkinsXCLI

}

Function global:K8sFuzzKit_InstallDashboard  {

    $Location = Get-Location
    $usernameSSH = "root"
    $passwordSSH = ConvertTo-SecureString "vagrant" -AsPlainText -Force 
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usernameSSH, $passwordSSH

    $IPMasterNode = $K8sFuzzKitMasterNodes[0].Split(" ")[-2]
    $VMMasterName = $K8sFuzzKitMasterNodes[0].Split(" ")[-1]

$Command_InstallDashboard = @"
#!/bin/bash
kubectl create -f /shared/Dashboard/service_account.yml >> /shared/service_account_and_clusterrolebinding_dashboard.log
kubectl create -f /shared/Dashboard/ClusterRoleBinding.yml >> /shared/service_account_and_clusterrolebinding_dashboard.log
curl https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml > /shared/kubernetes-dashboard.yaml
kubectl apply -f /shared/kubernetes-dashboard.yaml
kubectl -n kube-system describe secret `$(kubectl -n kube-system get secret | grep admin-user | awk '{print `$1}') > /shared/bearer_token_dashboard.log
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:admin-user
"@

    $Command_InstallDashboard | K8sFuzzKit_OutUnix -Path $Location\shared\InstallDashboard.sh
    Start-Sleep -Seconds 2

    $Command_InstallDashboardExecute = "chmod 700 /shared/InstallDashboard.sh && /shared/InstallDashboard.sh"

    "@@@@@ Create a new SSHSession on $VMMasterName Server"
    New-SSHSession -ComputerName $IPMasterNode -Credential $cred -Force
    $SessionID = (Get-SSHSession).SessionId

    New-Item -Path .\shared\Dashboard -ItemType Directory
    Copy-Item .\ExternalTools\Dashboard\service_account.yml .\shared\Dashboard\service_account.yml
    Copy-Item .\ExternalTools\Dashboard\service_account.yml .\shared\Dashboard\ClusterRoleBinding.yml


    Invoke-SSHCommand -Command $Command_InstallDashboardExecute -SessionId $SessionID -TimeOut 600
    "@@@@@ Install and Configure Dashboard for managing the K8sFuzzKit Cluster with UI."

    Do
    {
        $SearchString = Select-String -Path .\shared\service_account_and_clusterrolebinding_dashboard.log -Pattern "serviceaccount/admin-user created"

        "Processing ... It will take few seconds to complete the installation ... Please Wait ..."  
        Start-Sleep -Seconds 5
  
    } While ($SearchString.Count -eq 0)

    " "
    Get-Content .\shared\service_account_and_clusterrolebinding_dashboard.log
    " " 
 
    "@@@@@ Remove the SSHSession on $VMMasterName Server"
    Remove-SSHSession $SessionID
    " "
}

Function global:K8sFuzzKit_StartKubectlProxy_Dashboard  {

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

    $TestDashboardUpandRunning = "kubectl get pods --namespace kube-system"
    

    Do
    {
        $Content = Invoke-Expression $TestDashboardUpandRunning
        
        "Wait for the kubectl proxy and kubernetes dashboard pods are all up and running in the cluster ... Please Wait ..."  
        Start-Sleep -Seconds 10
  
    } While (!($Content | select-string -pattern "kubernetes-dashboard" | select-string -pattern "1/1"))

    Start-Process "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

}