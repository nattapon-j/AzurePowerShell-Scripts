Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-WindowsFeature -Name DNS -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName "MCSA2016.local" `
    -DomainNetbiosName "MCSA2016" `
    -InstallDns `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force) `
    -Force
