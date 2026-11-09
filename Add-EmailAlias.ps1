$SessionExch = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://srsi-exc1/PowerShell" -Authentication Kerberos
Import-PSSession -Session $SessionExch

$users = Get-ADUser -Filter {mail -like "*mango.pl"} -Properties mail | select samaccountname, mail

$users = Get-ADUser kovki

Function CheckExists-UserMailbox {
	Param ($user)
	if ((Get-Mailbox -Identity $user.SamAccountName -ErrorAction SilentlyContinue) -ne $null) {
		return $true
	}
	else {
		return $false
	}
}

foreach ($user in $users) 
{
    if (CheckExists-UserMailbox $user)
    {
        $mbx = Get-Mailbox $user.SamAccountName
        $primaryEmail = "$(($user.givenName)[0]).$($user.Surname)@mango.pl"
        if ($mbx.EmailAddresses -notcontains "smtp:$primaryEmail")
        {
            $mbx.EmailAddresses += $primaryEmail
            Write-Host "Added: $primaryEmail"
        }
        $secondaryEmail = "$(($user.givenName)[0])$($user.Surname)@mango.pl"
        if ($mbx.EmailAddresses -notcontains "smtp:$secondaryEmail")
        {
            $mbx.EmailAddresses += $secondaryEmail
            Write-Host "Added: $secondaryEmail"
        }
        #$mbx | Update-List -Property EmailAddresses -Remove "K.@mango.pl"

        Set-Mailbox -Identity $user.SamAccountName -EmailAddresses ($mbx.EmailAddresses)
    }
}