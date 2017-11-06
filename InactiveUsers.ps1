import-module activedirectory
#This script will disable inactive users, and log which accounts were disabled.
#This script was written to ensure that we are meeting an information security metric.
#The metric requires that accounts that have not been used in 45 days be disabled.
#The script runs against x OU, y OU, and for the time being will exclude Mailboxes and Meeting Rooms.
#Theres really no reason to keep those enabled - but management wanted caution.

#Specifically it excludes the following OUs:
#   domain.local/x/No User Policies/Mailbox Accounts
#   domain.local/x/No User Policies/Meeting Rooms
#   domain.local/y/Distribution Lists
#
# Script written by Kevin McBride - @tallmega
date
echo ""
echo "DISABLING X ACCOUNTS THAT HAVE BEEN USED, BUT NOT FOR 45 DAYS:"
search-adaccount -accountinactive -searchbase "OU=x,DC=domain,DC=local" -usersonly -timespan "45" | 
where Enabled -eq "True" | # looks for enabled accounts
where LastLogonDate -notlike "" | # excludes accounts that haven't ever logged in
Where {$_.DistinguishedName -notlike "*OU=Mailbox Accounts,OU=No User Policies,OU=x,DC=domain,DC=local"} | #excludes Mailboxes
Where {$_.DistinguishedName -notlike "*OU=Meeting Rooms,OU=No User Policies,OU=x,DC=domain,DC=local"} | #excludes Meeting Rooms
#Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru |
select sAMAccountName, Enabled, LastLogonDate, PasswordExpired | Format-Table
echo " "
echo "DISABLING X ACCOUNTS THAT HAVE NEVER BEEN USED AND ARE OLDER THAN 45 DAYS:"
$ts = (get-date).AddDays(-45)
search-adaccount -accountinactive -searchbase "OU=x,DC=domain,DC=local" -usersonly -timespan "45" | 
where Enabled -eq "True" | # looks for enabled accounts
where LastLogonDate -eq $null | # that haven't ever been used
Where {$_.DistinguishedName -notlike "*OU=Mailbox Accounts,OU=No User Policies,OU=x,DC=domain,DC=local"} | #excludes Mailboxes
Where {$_.DistinguishedName -notlike "*OU=Meeting Rooms,OU=No User Policies,OU=x,DC=domain,DC=local"} | #excludes Meeting Rooms
get-aduser -Properties *| where whenCreated -lt $ts |
#Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru | 
select sAMAccountName, Enabled, Created, PasswordExpired | Format-Table  
echo " "
echo "DISABLING Y HAVE BEEN USED, BUT NOT FOR 45 DAYS:"
search-adaccount -accountinactive -searchbase "OU=y,DC=domain,DC=local" -usersonly -timespan "45" | 
where Enabled -eq "True" |
where LastLogonDate -notlike "" |
Where {$_.DistinguishedName -notlike "*OU=Distribution Lists,OU=y,DC=domain,DC=local"} |
#Disable-ADAccount –passthru |set-aduser -Description ((get-date).toshortdatestring()) –passthru |
select sAMAccountName, Enabled, LastLogonDate, PasswordExpired | Format-Table
echo " "
echo "DISABLING Y ACCOUNTS THAT HAVE NEVER BEEN USED AND ARE OLDER THAN 45 DAYS:"
$ts = (get-date).AddDays(-45)
search-adaccount -accountinactive -searchbase "OU=y,DC=domain,DC=local" -usersonly -timespan "45" | 
where Enabled -eq "True" |
where LastLogonDate -eq $null |
Where {$_.DistinguishedName -notlike "*OU=Distribution Lists,OU=y,DC=domain,DC=local"} | #excludes distribution list ou (mailboxes)
get-aduser -Properties *| where whenCreated -lt $ts | 
#Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru |
select sAMAccountName, Enabled, Created, PasswordExpired | Format-Table 
echo "Complete!"
