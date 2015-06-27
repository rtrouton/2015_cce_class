1. Create Advanced report with the following criteria:

FileVault 2 Status is Boot Partitions Encrypted

OR

FileVault 2 Status is All Partitions Encrypted

Report ID = 1
Name = FileVault 2 Encrypted Macs

2. Verify that the results of the report match with reality by spot-checking machines for their reported encryption status.

3. Build a script that leverages the JSS API to download the current results of an advanced computer search:

https://gist.github.com/rtrouton/ca271ee4148483ea9f55

4. Have a Mac available where the following conditions are true:

A. Enrolled in the same JSS from which you're pulling the information.
B. Normally able to communicate with that JSS at any time

5. Save script onto the Mac as /etc/periodic/daily/802.fv2report

6. Ensure script is executable by running the following command with root privileges:

chmod 755 /etc/periodic/daily/802.fv2report

The reason to save it to /etc/periodic/daily is that periodic will take care of running the script on a daily basis with root privileges. The numeric value in the script tells periodic in which order the script should be run.

For more information about this, see the link below:

http://www.jaharmi.com/2013/07/01/add_your_own_periodic_scripts_subfolders_and_launchd_tasks

7. Verify that the script is working by manually calling it:

sudo bash /etc/periodic/daily/802.fv2report

8. That should produce an XML file named similarly to that shown below:

/tmp/20150626092642-filevault2-encryption-report.xml