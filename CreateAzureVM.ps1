# Login to Azure Account 
# Azure Login (จะต้องเข้าสู่ระบบ Azure ก่อน)
Connect-AzAccount

# Define variables
# ตั้งค่าพื้นฐาน
$resourceGroupName = "rg-digapp-br-workload-sea-prod"   # ชื่อ Resource Group ที่ต้องการสร้าง
$location = "southeastasia"                             # Southeast Asia (Singapore)
$vnetName = "vnet-vista-br-sea-prod"                    # ชื่อ Virtual Network
$subnetName = "snet-vista-br-app-sea-prod"              # ชื่อ Subnet
$vmSize = "Standard_B2s"                                # ขนาด VM ที่ต้องการใช้
$diskType = "StandardSSD_LRS"
$imagePublisher = "MicrosoftWindowsServer"              # Publisher ของ Image
$imageOffer = "WindowsServer"                           # Offer ของ Image
$imageSku = "2022-datacenter-azure-edition-hotpatch"    # SKU ของ Image (Hotpatch edition)
$zone = 1                                               # Zone ที่จะสร้าง VM

$adminUsername = "azureuser"                            # ชื่อผู้ใช้ admin ของ VM
$adminPassword = "P@ssw0rd123!"                         # รหัสผ่านของ VM 

$vnetResourceGroupName = "rg-vista-br-network-sea-prod"
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $vnetResourceGroupName -ErrorAction SilentlyContinue
$subnetId = (Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet).Id

# ตั้งชื่อ VM แต่ละเครื่อง
$vmName = "MyVM01"


###
# Check if the NIC exists
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name "nic-$vmName" -ErrorAction SilentlyContinue

if ($nic -eq $null) {
    Write-Output "Network Interface 'nic-$vmName' does not exist. Creating a new one..."

 
    # สร้าง Network Interface โดยไม่มี Public IP
    $nic = New-AzNetworkInterface `
            -Name "nic-$vmName" `
            -ResourceGroupName $resourceGroupName `
            -Location $location `
            -SubnetId $subnetId 
    

    Write-Output "Network Interface 'nic-$vmName' created successfully."
} else {
    Write-Output "Network Interface 'nic-$vmName' already exists."
} 

###

# กำหนดค่าพื้นฐานของ VM
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize -Zone $zone |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object PSCredential -ArgumentList $adminUsername, (ConvertTo-SecureString -String $adminPassword -AsPlainText -Force)) |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version "latest" |
    Set-AzVMOSDisk -CreateOption FromImage -StorageAccountType $diskType |
    Set-AzVMBootDiagnostic -ResourceGroupName $resourceGroupName -Enable |
    Add-AzVMNetworkInterface -Id $nic.Id

# สร้าง VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -LicenseType "Windows_Server"
Write-Output "VM $vmName created."

# #################################

$VM = Get-AzVM -ResourceGroupName $resourceGroupName -Name "BLNP-DIGAPP02"
$vm.DiagnosticsProfile.BootDiagnostics

Set-AzVMBootDiagnostic -VM $VM -Enable 
Update-AzVM -VM $VM -ResourceGroupName <>

Remove-AzStorageAccount -ResourceGroupName "rg-digapp-br-workload-sea-prod" -Name "vistargdigblnp110611510"  -Confirm:$false -Verbose
