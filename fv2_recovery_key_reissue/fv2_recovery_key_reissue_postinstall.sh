#!/bin/bash

install_dir=`dirname $0`

fv2_username=fdeuser
fv2_password=$(openssl rand -base64 32)
fv2_user_name="FDE User"
fv2_user_hint="No hint for you!"
fv2_user_shell=/usr/bin/false
fv2_user_group=20
fv2_user_image="/Library/User Pictures/Fun/Chalk.tif"


function check_for_filevault() {
  filevault_encryption_check=`/usr/bin/fdesetup status | awk '/On/ {print $3}' | sed '$s/.$//'`
}

function create_temp_user() {
  /usr/bin/dscl . create /Users/${fv2_username}
  /usr/bin/dscl . passwd /Users/${fv2_username} ${fv2_password}
  /usr/bin/dscl . create /Users/${fv2_username} UserShell ${fv2_user_shell}
  /usr/bin/dscl . create /Users/${fv2_username} PrimaryGroupID ${fv2_user_group}
  /usr/bin/dscl . create /Users/${fv2_username} RealName "${fv2_user_name}"
  /usr/bin/dscl . create /Users/${fv2_username} Picture "${fv2_user_image}"
  /usr/bin/dscl . create /Users/${fv2_username} Hint "${fv2_user_hint}"
}

function delete_temp_user() {
  /usr/bin/dscl . delete /Users/${fv2_username}
}

function add_user_to_filevault() {
$install_dir/108_fdesetup add -inputplist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Username</key>
<string>$fv2_username</string>
<key>Password</key>
<string>$fv2_password</string>
<key>AdditionalUsers</key>
<array>
    <dict>
        <key>Username</key>
        <string>$fv2_username</string>
        <key>Password</key>
        <string>$fv2_password</string>
    </dict>
</array>
</dict>
</plist>
EOF
}

function new_recovery_key() {
echo "Issuing new recovery key..."
/usr/bin/fdesetup changerecovery -personal -inputplist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Password</key>
    <string>$fv2_password</string>
</dict>
</plist>
EOF
}

check_for_filevault

if [[ "${filevault_encryption_check}" != "On" ]]; then
    echo "Cannot confirm FileVault encryption"
    exit 0
fi

if [[ "${filevault_encryption_check}" == "On" ]]; then
    create_temp_user
    add_user_to_filevault
    new_recovery_key
    delete_temp_user
fi

exit 0