#!/bin/bash
uname="1"
password_hash="1"

cat << "EOF"

NovaAbramson's
           __________  __  ______ 
          / ____/ __ \/ / / / __ )
         / / __/ /_/ / / / / __  |
        / /_/ / _ __/ /_/ / /_/ / 
        \____/_/ |_|\____/_____/  
                  __          __          
   ___  _______  / /____ ____/ /____  ____
  / _ \/ __/ _ \/ __/ -_) __/ __/ _ \/ __/
 /  __/_/  \___/\__/\__/\__/\__/\___/_/   
/_/                                       

EOF

# Bootloader username create
create_grub_username() {
    local uname1
    local uname2

    read -sp "Enter new GRUB username: " uname1
    echo
    read -sp "Enter username again: " uname2
    echo

    if [ "$uname1" == "$uname2" ]; then
        uname=$uname1
        echo "$uname"
    else
        echo "Usernames doesn't match. Try again."
    fi
}

# Password create
create_grub_password() {
    grub-mkpasswd-pbkdf2 | tee grub_password
    sed -i '/Enter password:/,/Reenter password:/d' grub_password
    sed -i 's/PBKDF2 hash of your password is / /g' grub_password
    password_hash=$(<grub_password)
    rm grub_password
}

# Ask password with every load
set_grub_password_normal() {
    chmod 757 /etc/grub.d/40_custom
    echo "set superusers="$uname"" >> /etc/grub.d/40_custom
    echo "password_pbkdf2 $uname $password_hash" >> /etc/grub.d/40_custom
    chmod 755 /etc/grub.d/40_custom
    update-grub
}

# Ask password with edited load
set_grub_password_advanced() {
    chmod 757 /etc/grub.d/40_custom
    chmod 757 /etc/grub.d/10_linux
    echo 'set superusers="'"$uname"'"' >> /etc/grub.d/40_custom
    # echo "set superusers="$uname"" >> /etc/grub.d/40_custom
    echo "password_pbkdf2 $uname $password_hash" >> /etc/grub.d/40_custom
    sed -i 's/CLASS="--class gnu-linux --class gnu --class os"/CLASS="--class gnu-linux --class gnu --class os --unrestricted"/' /etc/grub.d/10_linux
    chmod 755 /etc/grub.d/40_custom
    chmod 755 /etc/grub.d/10_linux
    update-grub
}

# Menu
echo "1. Ask password with every OS load"
echo "2. Ask password with edited parameters OS load"
echo "3. Exit"
echo " "
read -p "Select option: " choice

case $choice in
    1)
        create_grub_username
        create_grub_password
        set_grub_password_normal
        ;;
    2)
        create_grub_username
        create_grub_password
        set_grub_password_advanced
        ;;
    3)
        exit 0
        ;;
    *)
        echo "Select option: " choice
        ;;
esac

echo ""
echo ""
echo "Grub password set successful"
sleep 5000
exit 0