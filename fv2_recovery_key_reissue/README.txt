Detect manually encrypted Macs and get personal recovery keys into the JSS

NOTE: This should not never, never, never, really not ever be used in a production environment. 

Really. Not kidding.

Seriously.

No.


Tools used:

Packages - http://s.sudre.free.fr/Software/Packages/about.html
10.8's fdesetup - https://derflounder.wordpress.com/2014/11/14/using-os-x-10-8s-fdesetup-tool-and-non-enabled-admin-accounts-to-enable-users-for-filevault-2-on-mavericks-and-yosemite/


1. Set up smart group to detect the following:

Name: FileVault Encrypted and Unknown Personal Recovery Key


Criteria:

FileVault 2 Individual Key Validation IS Unknown

or

FileVault 2 Individual Key Validation IS Invalid

AND

FileVault 2 Status IS Boot Partitions Encrypted

or

FileVault 2 Status IS All Partitions Encrypted


2. Set up configuration profile:

Type: FileVault Recovery Key Redirection
Method: Automatically redirect recovery keys to the JSS

3. Set up "Change FileVault 2 Personal Recovery Key" installer package

Components:

10.8's fdesetup binary
Postinstall script

Postinstall - https://gist.github.com/rtrouton/0fdfbf413a5edea1b933

Postinstall script does the following:

A. Sets up temporary user account with randomized password
B. Uses 10.8's fdesetup to enable the temporary user account for FileVault 2
C. Uses the temporary user account's password with the OS's fdesetup to authorize a change to a new personal recovery key for the machine
D. The temporary user account is deleted (which also removes the account from the list of FileVault 2-enabled users.)

4. Set up policy on the JSS to do the following:

Check for machines in the "FileVault Encrypted and Unknown Personal Recovery Key" smart group
Install "Change FileVault 2 Personal Recovery Key" installer package
Run Inventory Update

5. Tested by setting up a VM to be encrypted with a personal recovery key which wasn't stored on the JSS.

6. Verified that the VM had the following status for the recovery key after the policy's run:

Individual Recovery Key Validation: Valid