Add-Computer -DomainName "MCSA2016.local" `
    -Credential (New-Object PSCredential("MCSA2016\\Administrator", (ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force))) `
    -Restart `
    -Force
