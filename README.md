# DISABLE INACTIVE USERS
This script will disable inactive users, service accounts and log which accounts were disabled.
It also clears the passwordneverexpires flag.

This script was written to ensure that we are meeting an information security metric, as well as to help prevent credential theft attacks such as Password Spraying, Kerberoasting, etc.

The metric requires that user accounts that have not been used in 45 days be disabled, and service accounts not used in 2 years be disabled.

The script runs against all OUs unless specified.
There's really no reason to exclude any but management wanted caution and I thought exclusion examples might be useful to some.

In order to automate this, just set it as a scheduled task:
  Choose a User with permission to disable accounts
  
  Select Run whether the user is logged in or not.
  
  Under actions, choose 'New' with the following options:
  
  Action: Start a Program
  
  Program/Script: Powershell
  
  Add Arguments: C:\<path>\InactiveUsers45.ps1 >> C:\<path>\InactiveUsers.log
  
  Then just set it to run as often as you need to.

Written by Kevin McBride (@tallmega) with lots of help from The Internet.
