Task - Reimage machine while preserving user folders

Specfied OS configuration
-------------------------

OS X 10.10.3
Firefox
TextWrangler

Tools used:

AutoPkg - http://autopkg.github.io/autopkg
AutoDMG - https://github.com/MagerValp/AutoDMG
BackupRestore - https://github.com/rustymyers/BackupRestore
Create Recovery Partition Installer - https://github.com/MagerValp/Create-Recovery-Partition-Installer
DeployStudio 1.6.15 - http://www.deploystudio.com
VMware Fusion - http://www.vmware.com/products/fusion
Mac OS X Server 10.6.8

1. Set up DeployStudio server in a Mac OS X 10.6.8 Server VM

IP: 192.168.1.137
DNS: deploystudio.local

2. Add the following scripts and packages to DeployStudio

Packages:

TextWrangler 4.5.12
Firefox 38.0.5

Both packages were built with AutoPkg

Scripts:

DS_BACKUP_DATA.sh
DS_RESTORE_DATA.sh

Link: https://github.com/rustymyers/BackupRestore
More information: http://rustyisageek.blogspot.com/p/backuprestore-scripts.html

3. Build a new 10.10.3 image with AutoDMG

osx-10.10.3-14D136.hfs.dmg

4. Add the 10.10.3 image to DeployStudio

5. Build 10.10.3 Recovery HD installer package with Create-Recovery-Partition-Installer

RecoveryPartitionInstaller-10.10.3.pkg

6. Add 10.10.3 Recovery HD installer package to DeployStudio

7. Create new workflow in DeployStudio

Casper CCE Wipe and Preserve Users

Component tasks

Time - sets desired time zone and sets an NTP server for the Mac.
Hostname -  Allows user input to set preferred hostname for the Mac
DS_BACKUP_DATA.sh - backs up user folders and local user information from Mac
Restore - erases drive and images the drive with osx-10.10.3-14D136.hfs.dmg
Package install - installs RecoveryPartitionInstaller-10.10.3.pkg at first boot
Configure - runs the following tasks at first boot

Rename computer - names machine with the hostname entered in the Hostname task
Rename ByHost prefs - ensures that all user preferences that use ByHost information are updated
Skip Apple Setup/Server Assistant - Allows Mac to bypass the Setup Assistant


Package install - Installs TextWrangler at first boot
Package install - Installs Firefox at first boot
DS_RESTORE_DATA.sh - restores backed-up user folders and local user information back to the Mac

8. Built new 10.10.3 DeployStudio boot set

Tools used:

DeployStudio - http://www.deploystudio.com
AutoDSNBI.sh - http://magervalp.github.io/2014/05/27/autodsnbi.html

Set DeployStudio boot set to access the DeployStudio server at the following address:

https://deploystudio.local:60443

9. Set up the NetBoot service on the 10.6.8 Server VM to host the DeployStudio boot set.

10. Booted CCE-provided 10.10.3 VM and verified that there was an existing local user:

Username: ladmin
Home folder: /Users/ladmin

11. Added folder named TEST to the desktop of the ladmin user

12. Went into Startup Disk in VM and set the DeployStudio boot set as the startup drive.

13. Shut down CCE-provided 10.10.3 VM and made a pre-imaging snapshot

14. After snapshot was complete, booted the VM from the DeployStudio boot set by starting the VM and holding down the N key on the keyboard.

15. Logged into DeployStudio

16. Selected and ran the "Casper CCE Wipe and Preserve Users" workflow

17. When prompted, I set the hostname to be the following:

computername

18. Verified that the DS_BACKUP_DATA.sh script backed up the user folder and account plists

19. Verified that the other tasks in the workflow ran correctly

20. Verified that the DS_RESTORE_DATA.sh script restored the user folder and plist files.

21. Rebooted the VM once the workflow completed.

22. Verified the following packages installed at first boot:

RecoveryPartitionInstaller-10.10.3.pkg
Firefox
TextWrangler

23. Once packages were finished installing, I verified that the Mac rebooted normally.

24. After the reboot, I verified that the ladmin account was showing at the loginwindow

25. Logged in as ladmin and verified that the TEST folder was available on the desktop.