Add-Computer -DomainName "MCSA2016.local" `
    -Credential (New-Object PSCredential("MCSA2016\\adminuser", (ConvertTo-SecureString "AdminPassword1234!" -AsPlainText -Force))) `
    -Restart `
    -Force
