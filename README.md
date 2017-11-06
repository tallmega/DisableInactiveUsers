This script will disable inactive users, and log which accounts were disabled.
This script was written to ensure that we are meeting an information security metric.  The metric requires that accounts that have not been used in 45 days be disabled.

The script runs against x OU, y OU, and for the time being will exclude Mailboxes and Meeting Rooms.
Theres really no reason to keep those enabled - but management wanted caution and I thought exclusion examples might be useful to some.

In order to automate this, just set it as a scheduled task:

Choose a User with permission to disable accounts
Select Run whether the user is logged in or not.

Under actions, choose 'New' with the following options:
Action: Start a Program
Program/Script: Powershell
Add Arguments: C:\CustomScripts\InactiveUsers45.ps1 >> C:\CustomScripts\InactiveUsers.log

Then just set it to run as often as you need to.

Written by Kevin McBride (@tallmega) with lots of help from The Internet.
