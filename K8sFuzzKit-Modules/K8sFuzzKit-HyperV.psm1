# Function to create a Virtual Switch Internal 
Function global:K8sFuzzKit_Create_vSwitch {
    Param(
            [Parameter(Mandatory=$True,
                        Position=0)]
            [String]$vSwitchName,

            [Parameter(Mandatory=$True,
                        Position=1)]
            [Bool]$ForceRemovevSwitch
    )

    # Check if the vSwitch already exist. Create it if not present (force removing the vSwitch before create it if $ForceRemovevSwitch is true).
    $K8sFuzzKit_VirtualSwitch = Get-VMSwitch -SwitchName $vSwitchName -ErrorAction SilentlyContinue
  
    if($K8sFuzzKit_VirtualSwitch) {            
            if ($ForceRemovevSwitch) {
                Write-Host "The vSwitch $vSwitchName is already present. You want to recreate it."
                Write-Host "Remove the vSwith $vSwitchName." 
                " "
                Remove-VMSwitch -SwitchName $vSwitchName -Force 

                Write-Host "Please Wait creating the vSwitch $vSwitchName." 
                " "
                New-VMSwitch -SwitchName $vSwitchName -SwitchType Internal                
                } else {             
                Write-Host "The vSwitch $vSwitchName is already present. No action to perform for creating this vSwitch."
                " "
                } 
            } else {
            Write-Host "Please Wait creating the vSwitch $vSwitchName."
            " "
            New-VMSwitch -SwitchName $vSwitchName -SwitchType Internal            
    }

    # Call the function Set-IP-and-Netmask-vSwitch-K8sFuzzKit for setting the IP/Netmask & Nat the vSwitch
    K8sFuzzKit_SetIP_Netmask_vSwitch $vSwitchName
}

# Function to get the interface index of the vSwitch and then set the IP/NetMask & Nat the vSwitch for for K8sFuzzKit
Function global:K8sFuzzKit_SetIP_Netmask_vSwitch {
    Param(
            [Parameter(Mandatory=$False,
                        Position=0)]
            [String]$vSwitchName
    )
    
   
    if(!((Get-NetAdapter -Name "vEthernet ($vSwitchName)" -ErrorAction SilentlyContinue).ifIndex) ) {
            New-VMSwitch -SwitchName $vSwitchName -SwitchType Internal    
    }

    $IF_INDEX = (Get-NetAdapter -Name "vEthernet ($vSwitchName)").ifIndex
        
    if(!((Get-NetIPAddress -InterfaceIndex $IF_INDEX -ErrorAction SilentlyContinue).IPv4Address -eq "${env:K8sFuzzKit_VM_BASE_SUBNET}1")) {
            New-NetIPAddress -IPAddress "${env:K8sFuzzKit_VM_BASE_SUBNET}1"  -PrefixLength 24 -InterfaceIndex $IF_INDEX | Out-Null    
    } 
        

    if(!(Get-NetNat -Name $vSwitchName -ErrorAction SilentlyContinue)) { 
    "${env:K8sFuzzKit_VM_BASE_SUBNET}0/24"
            New-NetNat -Name $vSwitchName -InternalIPInterfaceAddressPrefix ${env:K8sFuzzKit_VM_BASE_SUBNET}0/24 | Out-Null 
        } else {
            $InternalIPInterfaceAddressPrefix = (Get-NetNat -Name $vSwitchName -ErrorAction SilentlyContinue).InternalIPInterfaceAddressPrefix
            
                if (!($InternalIPInterfaceAddressPrefix -match ${env:K8sFuzzKit_VM_BASE_SUBNET})) {
                    Remove-NetNat -Name (Get-NetNat).Name -Confirm:$False
                    New-NetNat -Name $vSwitchName -InternalIPInterfaceAddressPrefix "${env:K8sFuzzKit_VM_BASE_SUBNET}0/24" | Out-Null
                }
    }
	
	Start-Sleep -Milliseconds 500
}
