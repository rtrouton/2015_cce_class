Challenge:

Redundant backups of JSS's MySQL database

1. Set up the JSS Database Utility to make nightly backups of the JSS database.

Runs at: 2:00 AM everyday

Settings: delete backups older than 7 days

Backup directory: /usr/local/jss/backups/


2. Set up second CentOS server (using VM) with separate IP and DNS name:

IP: 192.168.1.112
DNS: backup.demo.com


3. Created new user named "backup" on backup.demo.com

Username: backup
Home: /home/backup


4. On JSS, log in via SSH


5. Switch to the root user by running the following command:

su root


6. Once in root, run the following command to create an SSH key

ssh-keygen

Note: Passphrase was left as empty.


7. Running ssh-keygen created a public and private keypair in /root/.ssh:

id_rsa - private key
id_rsa.pub - public key


8. Created a copy of the "id_rsa.pub" public key and named it "id_rsa_backup.pub". The "id_rsa_backup.pub" public key will be used to make a passwordless SSH connection later in this process.


9. Created the folder structure for the SSH key and backup destination on backup.demo.com by running the following commands remotely from my JSS:

ssh backup@backup.demo.com "mkdir -p /home/backup/.ssh"
ssh backup@backup.demo.com "chmod 700 /home/backup/.ssh"
ssh backup@backup.demo.com "touch /home/backup/.ssh/authorized_keys"
ssh backup@backup.demo.com "chmod 600 /home/backup/.ssh/authorized_keys"
ssh backup@backup.demo.com "mkdir -p /home/backup/jssdbbackup"

chmod 600 was used to ensure that only the backup user could read and write to /home/backup/.ssh/authorized_keys
chmod 700 was used to ensure that only the backup user could read and write to /home/backup/.ssh


10. Used the following command to copy the public key using SCP from the JSS server to the backup user's home directory on backup.demo.com:

scp /root/.ssh/id_rsa.pub backup@backup.demo.com:/home/backup/backup_key.pub


11. Remotely used cat to write the public key to /home/backup/.ssh/authorized_keys with the following command:

ssh backup@backup.demo.com "cat /home/backup/backup_key.pub >> /home/backup/.ssh/authorized_keys"


12. Set up an rsync job to synchronize the contents of /usr/local/jss/backups/ on the JSS server with /home/backup/jssdbbackup on backup.demo.com:

rsync -avz --delete -e "ssh -i /root/.ssh/id_rsa_backup" /usr/local/jss/backups backup@backup.demo.com:/home/backup/jssdbbackup

Note: the rsync job will keep the two directories in sync with each other. As backups are deleted from /usr/local/jss/backups/ on the JSS server, they will also be deleted from /home/backup/jssdbbackup on backup.demo.com.


13. Verified that the root crontab was set to back up the JSS database nightly at 2:00 AM

0 2 * * * java -jar "/usr/local/jss/bin/JSSDatabaseUtil.jar" backup -auto -deleteBackupsOlderThanDays 7 2>&1 >> /dev/null


14. Added an entry to the root crontab to run the rsync job nightly at 5:30 AM:

30 5 * * *  /usr/bin/rsync -avz --delete -e "ssh -i /root/.ssh/id_rsa_backup" /usr/local/jss/backups backup@backup.demo.com:/home/backup/jssdbbackup 2>&1 >> /dev/null


15. Manually ran a backup of the JSS database using the following command:

java -jar "/usr/local/jss/bin/JSSDatabaseUtil.jar" backup -auto -deleteBackupsOlderThanDays 7


16. Verified that the rsync job was able to copy backups by running the following command with root privileges:

rsync -avz --delete -e "ssh -i /root/.ssh/id_rsa_backup" /usr/local/jss/backups backup@backup.demo.com:/home/backup/jssdbbackup


17. rsync ran successfully and sync'd the contents of /usr/local/jss/backups/ on the JSS server with /home/backup/jssdbbackup on backup.demo.com:

[root@casper .ssh]# rsync -avz --delete -e "ssh -i /root/.ssh/id_rsa_backup" /usr/local/jss/backups backup@backup.demo.com:/home/backup/jssdbbackup
Warning: Identity file /root/.ssh/id_rsa_backup not accessible: No such file or directory.
sending incremental file list
backups/
backups/database/
backups/database/auto-2015-06-23_13-16-35.sql.gz

sent 1295226 bytes  received 39 bytes  2590530.00 bytes/sec
total size is 1294627  speedup is 1.00
[root@casper .ssh]#

18. Verified that the cronjobs executed by changing them to the following at 2:48 PM:

50 14 * * * java -jar "/usr/local/jss/bin/JSSDatabaseUtil.jar" backup -auto -deleteBackupsOlderThanDays 7 2>&1 >> /dev/null
52 14 * * *  /usr/bin/rsync -avz --delete -e "ssh -i /root/.ssh/id_rsa_backup" /usr/local/jss/backups backup@backup.demo.com:/home/backup/jssdbbackup 2>&1 >> /dev/null

19. Verified at 2:53 PM that a new backup was now available on the JSS server and the backup had been sync'd from /usr/local/jss/backups/ on the JSS server to /home/backup/jssdbbackup on backup.demo.com.