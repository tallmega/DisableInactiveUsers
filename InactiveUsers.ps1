import-module activedirectory
# This script will disable inactive users, service accounts and log which accounts were disabled.
# It also clears the passwordneverexpires flag.
# This script was written to ensure that we are meeting an information security metric.
# The metric requires that user accounts that have not been used in 45 days be disabled, and service accounts not used in 2 years be disabled.

# The script runs against all OUs unless specified.
# Theres really no reason to exclude any but management wanted caution and I thought exclusion examples might be useful to some.

# In order to automate this, just set it as a scheduled task:
#   Choose a User with permission to disable accounts
#   Select Run whether the user is logged in or not.
#   Under actions, choose 'New' with the following options:
#   Action: Start a Program
#   Program/Script: Powershell
#   Add Arguments: C:\<path>\InactiveUsers.ps1 >> C:\<path>\InactiveUsers.log
#   Then just set it to run as often as you need to.
# Written by Kevin McBride (@tallmega) with lots of help from The Internet.

date
echo ""
echo "DISABLING USER ACCOUNTS THAT HAVE BEEN USED, BUT NOT FOR 45 DAYS:"
search-adaccount -accountinactive  -usersonly -timespan "45" | 
where Enabled -eq "True" | # looks for enabled accounts
where LastLogonDate -notlike "" | # excludes accounts that haven't ever logged in
where {$_.DistinguishedName -notlike "*OU=Service Accounts,DC=domain,DC=local"} | #excludes service accounts
where {$_.DistinguishedName -notlike "*CN=Users,DC=domain,DC=local"} | #excludes default account - !! exclusion should be removed
Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru | Set-ADUser -PasswordNeverExpires:$False -passthru |
select sAMAccountName, Enabled, LastLogonDate, PasswordExpired, distinguishedname | Format-Table
echo " "
echo "DISABLING USER ACCOUNTS THAT HAVE NEVER BEEN USED AND ARE OLDER THAN 45 DAYS:"
$ts = (get-date).AddDays(-45)
search-adaccount -accountinactive -usersonly -timespan "45" | 
where Enabled -eq "True" | # looks for enabled accounts
where LastLogonDate -eq $null | # that haven't ever been used
where {$_.DistinguishedName -notlike "*OU=Service Accounts,DC=domain,DC=local"} | #excludes service accounts
where {$_.DistinguishedName -notlike "*CN=Users,DC=domain,DC=local"} | #excludes default ou - !! exclusion should be removed
get-aduser -Properties *| where whenCreated -lt $ts |
Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru | Set-ADUser -PasswordNeverExpires:$False -passthru |
select sAMAccountName, Enabled, Created, PasswordExpired, distinguishedname | Format-Table  
echo " "
echo "DISABLING SERVICE ACCOUNTS THAT HAVE BEEN USED, BUT NOT FOR 2 YEARS:"
search-adaccount -accountinactive -searchbase "OU=Service Accounts,DC=domain,DC=local" -usersonly -timespan "730" | 
where Enabled -eq "True" | # looks for enabled accounts
where LastLogonDate -notlike "" | # excludes accounts that haven't ever logged in
Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru |
select sAMAccountName, Enabled, LastLogonDate, PasswordExpired, distinguishedname | Format-Table
echo " "
echo "DISABLING SERVICE ACCOUNTS THAT HAVE NEVER BEEN USED AND ARE OLDER THAN 2 YEARS:"
$ts = (get-date).AddDays(-730)
search-adaccount -accountinactive -searchbase "OU=Service Accounts,DC=domain,DC=local" -usersonly -timespan "730" | 
where Enabled -eq "True" | # looks for enabled accounts
where LastLogonDate -eq $null | # that haven't ever been used
get-aduser -Properties *| where whenCreated -lt $ts | #created more than 2 years ago
Disable-ADAccount –passthru | set-aduser -Description ((get-date).toshortdatestring()) –passthru |
select sAMAccountName, Enabled, Created, PasswordExpired, distinguishedname | Format-Table  
echo "Complete!"
