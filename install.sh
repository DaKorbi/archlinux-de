#! /bin/bash

if [ $1 == '1' ]; then
loadkeys de-latin1
echo "WARNUNG: Wenn Sie mit der Installation fortfahren wird ihre gesammte Festplatte gelöscht"
echo "Trotzdem fortfahren? (J/N)"
read ffh
if [ $ffh == "J" ]; then
echo "Löschen der Festplatte..."
dd if=/dev/zero of=/dev/sda count=1000000
echo "Die Konfiguration unter gdisk muss manuel durchgeführt werden, Hilfe finden Sie hier: https://wiki.archlinux.de/title/GPT#Partitionieren_mit_gdisk"
echo "8300: Linux Filesystem"
echo "8200: Swap"
echo "ef02: Grub"
gdisk /dev/sda
mkfs.ext4 -L arch /dev/sda1
mkswap -L swap /dev/sda2
mount /dev/sda1 /mnt
swapon /dev/sda2
wget -q --spider http://google.de
if [ $? -eq 0 ]; then
echo "Verbindung Vorhanden"
else
#error
echo "Wlan-Verbindung herstellen"
#wifi-menu
ip link
echo "WLAN-Interface-Name: "
read interface
echo "WLAN-SSID: "
read ssid
echo "WLAN-Passwort: "
read password
wpa_passphrase $ssid $password  > /etc/wpa_supplicant/wpa_supplicant.conf
wpa_supplicant -i $interface -D wext -c /etc/wpa_supplicant/wpa_supplicant.conf -B
dhcpcd $interface
fi
pacstrap /mnt base base-devel wpa_supplicant
genfstab -p /mnt > /mnt/etc/fstab
echo "Die generierte fstab:"
cat /mnt/etc/fstab
echo "Jetzt gehts im arch-chroot weiter.Danach einfach sh /pfad/zum/script.sh 2 zum weitermachen"
arch-chroot /mnt/
else
exit
fi
fi

if [ $1 == '2' ]; then
echo "Name deines Rechners: "
read hostname
echo $hostname > /etc/hostname
echo LANG=de_DE.UTF-8 > /etc/locale.conf
echo LC_COLLATE=C >> /etc/locale.conf
echo LANGUAGE=de_DE >> /etc/locale.conf
echo KEYMAP=de-latin1 > /etc/vconsole.conf
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
echo "Jetzt im locale.gen #de_DE mit Ctrl+W suchen und zu de_DE auskommentieren (insgesammt müssen 3 # entfernt werden)/ndanach mit Ctrl+O speichern und mit Ctrl+X beenden"
nano /etc/locale.gen
locale-gen
mkinitcpio -p linux
echo "Root-Passwort festlegen..."
passwd
pacman -S grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sda
echo "jetzt noch der Reihe nach: (exit) (umount /mnt) (reboot)"
fi
