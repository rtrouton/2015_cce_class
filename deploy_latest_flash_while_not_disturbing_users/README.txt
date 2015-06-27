Deploy Flash but ensure all common browsers aren't running and don't disturb the users

Premise:

Browsers won't be running and users won't be disturbed if the install happens while they're starting up or logged out.

1. Set up policy to deploy latest Flash update

Name: Push Install Latest Flash
Trigger: Custom event - installflash
Package: Install Latest Adobe Flash Player.pkg
Maintenance: Update Inventory

Install Latest Adobe Flash Player.pkg available from GitHub:

https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/install_latest_adobe_flash_player

2. Set up script named "Deploy Latest Flash While Not Disturbing Users" which deploys a separate script and LaunchDaemon

A. LaunchDaemon runs script at startup and every five minutes
B. Script checks for all users to be logged out of the console. (AKA logged into the GUI via the OS loginwindow.)

Note: Users who are logged-in, but where Fast User Switching has switched back to the login window, will still show up as being logged into the console.

C. Once all users are verified to be logged out of the console, script runs a Casper policy via a custom trigger. 

Note: In this case, the script is calling the "installflash" custom trigger.

https://gist.github.com/rtrouton/c4d0104295261acbf61f


3. Set up policy to run the "Deploy Latest Flash While Not Disturbing Users" script on the appropriate Macs.

4. Flash will be installed by Casper either when the Macs start up or during a time when all users are logged out of the console.