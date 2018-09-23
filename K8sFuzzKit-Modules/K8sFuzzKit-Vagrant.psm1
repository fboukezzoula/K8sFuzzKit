Function global:K8sFuzzKit_CopyAndPrepare_Vagrantfile {

    param ($VagrantfilePath)

    Copy-Item $VagrantfilePath -Destination . -Force

    # Create the final Vagrantfile by replacing several variables
    $Vagrantfile ="Vagrantfile"
    (Get-Content $Vagrantfile).replace('##TOTAL_MANAGER_NODES##', "$env:K8sFuzzKit_NbrK8sManager") | Set-Content $Vagrantfile
    (Get-Content $Vagrantfile).replace('##TOTAL_WORKER_NODES##', "$env:K8sFuzzKit_NbrK8sWorker") | Set-Content $Vagrantfile
    (Get-Content $Vagrantfile).replace('##BASE_IPADDRESS##', "$env:BASE_IPADDRESS") | Set-Content $Vagrantfile   
  
}

Function global:K8sFuzzKit_CommandVagrant_Valide_Up_Reload {

    $VagrantCommandValidate = "vagrant validate"
    $VagrantCommandUpReload = "vagrant up; vagrant reload"
               
    Invoke-Expression $VagrantCommandValidate 
    Invoke-Expression $VagrantCommandUpReload 
    " "
}
