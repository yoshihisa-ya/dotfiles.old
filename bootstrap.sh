#/bin/bash${TARGET}

pacman-key --populate archlinux >/dev/null 2>&1
ret=$?
if [ $ret != 0 ]; then
    echo "Failed pacman-key refresh." >&2
    exit 1
fi

SHRED=true
FORCE=false

BIOS=true
SECUREBOOT=false
test -d /sys/firmware/efi && {
    BIOS=false
    SECUREBOOT=true
}

DEVICE=/dev/null
if test -b /dev/nvme0n1; then
    DEVICE=/dev/nvme0n1
elif test -b /dev/vda; then
    DEVICE=/dev/vda
elif test -b /dev/sda; then
    DEVICE=/dev/sda
fi

LUKS_DEVICE=btrfs_crypt
TARGET=/target
USERNAME=yoshihisa
SWAPFILE=8

while getopts d:l:h:p:r:nu:s:f OPT; do
    case $OPT in
    d)
        DEVICE=$OPTARG
        ;;
    l)
        LUKS_PASSWORD=$OPTARG
        ;;
    h)
        HOST=$OPTARG
        ;;
    p)
        PASSWORD=$OPTARG
        ;;
    r)
        PASSWORD_ROOT=$OPTARG
        ;;
    n)
        SHRED=false
        ;;
    u)
        USERNAME=$OPTARG
        ;;
    s)
        SWAPFILE=$OPTARG
        ;;
    f)
        FORCE=true
        ;;
    esac
done

[ -v HOST ] || read -p "Hostname(FQDN): " HOST
[ -v LUKS_PASSWORD ] || read -sp "LUKS password: " LUKS_PASSWORD
[ -v PASSWORD_ROOT ] || read -sp "root password(if empty lock): " PASSWORD_ROOT
[ -v PASSWORD ] || read -sp "${USERNAME} password: " PASSWORD

if ! test -b ${DEVICE}; then
    echo "No such block device" >&2
    exit 1
fi

disp_bios=UEFI
${BIOS} && disp_bios=BIOS
disp_chars=$(echo -n "shred -n 1 ${DEVICE}: " | wc -c)
printf "%-${disp_chars}s %s\n" "Platform:" ${disp_bios}
printf "%-${disp_chars}s %s\n" "SecureBoot:" ${SECUREBOOT}
printf "%-${disp_chars}s %s\n" "Block Device:" ${DEVICE}
printf "%-${disp_chars}s %s\n" "shred -n 1 ${DEVICE}:" ${SHRED}
printf "%-${disp_chars}s %s\n" "HOSTNAME:" ${HOST}
printf "%-${disp_chars}s %s\n" "USER:" ${USERNAME}
printf "%-${disp_chars}s %d\n" "SWAPFILE(GiB):" ${SWAPFILE}
echo ""

if ! ${FORCE}; then
    echo -n "Continue? [y/N]: "
    read cont
    if [ "${cont:-"N"}" != "y" ]; then
        exit 1
    fi
fi

set -eu

timedatectl set-ntp true
test -d ${TARGET} || mkdir ${TARGET}

# Shred
if ${SHRED}; then
    shred -n 1 -v ${DEVICE}
fi

# Partition
sgdisk --zap-all ${DEVICE}
sgdisk --new 1::+512M ${DEVICE}
sgdisk --typecode 1:ef00 ${DEVICE}
sgdisk --new 2:: ${DEVICE}
sgdisk --typecode 2:8308 ${DEVICE}
mkfs.fat -F32 ${DEVICE}1

gdisk -l ${DEVICE}

# LUKS
echo ${LUKS_PASSWORD} | cryptsetup -q -s 512 luksFormat ${DEVICE}2
echo ${LUKS_PASSWORD} | cryptsetup luksOpen ${DEVICE}2 ${LUKS_DEVICE}

# Btrfs
device_luks_device="/dev/mapper/${LUKS_DEVICE}"
mkfs.btrfs ${device_luks_device}
mount ${device_luks_device} /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @var_log
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@ ${device_luks_device} ${TARGET}
mkdir -p ${TARGET}/boot/efi
mount ${DEVICE}1 ${TARGET}/boot/efi
mkdir ${TARGET}/home
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@home ${device_luks_device} ${TARGET}/home
mkdir -p ${TARGET}/var/log
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@var_log ${device_luks_device} ${TARGET}/var/log

# Packages
pacstrap -c ${TARGET} base base-devel linux networkmanager vi cryptsetup device-mapper inetutils linux-firmware logrotate btrfs-progs openssh

# Network
echo ${HOST%%.*} >/target/etc/hostname
echo "127.0.0.1 ${HOST}  ${HOST%%.*}" >>/target/etc/hosts
arch-chroot ${TARGET} systemctl enable NetworkManager.service

# Daemon
arch-chroot ${TARGET} systemctl enable sshd

# Generate fstab
btrfs subvolume create @var_cache_pacman_pkg
btrfs subvolume create @var_lib_libvirt_images
chattr +C @var_lib_libvirt_images
mkdir -p ${TARGET}/var/lib/libvirt/images
echo "${device_luks_device}  /                       btrfs      rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@                       0 0" >>${TARGET}/etc/fstab
genfstab -U ${TARGET} | grep -B1 /boot/efi >>${TARGET}/etc/fstab
echo "${device_luks_device}  /home                   btrfs      rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@home                   0 0" >>${TARGET}/etc/fstab
echo "${device_luks_device}  /var/log                btrfs      rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@var_log                0 0" >>${TARGET}/etc/fstab
echo "${device_luks_device}  /var/cache/pacman/pkg   btrfs      rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@var_cache_pacman_pkg   0 0" >>${TARGET}/etc/fstab
echo "${device_luks_device}  /var/lib/libvirt/images btrfs      rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@var_lib_libvirt_images 0 0" >>${TARGET}/etc/fstab

# Swapfile
btrfs subvolume create @swapfile
chattr +C @swapfile
mkdir ${TARGET}/swapfile
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@swapfile ${device_luks_device} ${TARGET}/swapfile
truncate -s 0 ${TARGET}/swapfile/swapfile
chattr +C ${TARGET}/swapfile/swapfile
btrfs property set ${TARGET}/swapfile/swapfile compression none
fallocate -l ${SWAPFILE}G ${TARGET}/swapfile/swapfile
chmod 600 ${TARGET}/swapfile/swapfile
mkswap ${TARGET}/swapfile/swapfile
echo "${device_luks_device}  /swapfile               btrfs      rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@swapfile               0 0" >>${TARGET}/etc/fstab
echo "/swapfile/swapfile none swap defaults 0 0" >>${TARGET}/etc/fstab

# Locale, Timezone
arch-chroot ${TARGET} ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
arch-chroot ${TARGET} hwclock --systohc --utc
sed -i -e 's/#ja_JP.UTF-8/ja_JP.UTF-8/' ${TARGET}/etc/locale.gen
sed -i -e 's/#en_US.UTF-8/en_US.UTF-8/' ${TARGET}/etc/locale.gen
echo LANG=ja_JP.UTF-8 >${TARGET}/etc/locale.conf
arch-chroot ${TARGET} locale-gen

# Initramfs
sed -i 's/^HOOKS=/#HOOKS=/' ${TARGET}/etc/mkinitcpio.conf
sed -i '/^#HOOKS/aHOOKS=(base udev autodetect modconf keyboard keymap block encrypt filesystems fsck)' ${TARGET}/etc/mkinitcpio.conf

arch-chroot ${TARGET} mkinitcpio -p linux

# User
echo "root:${PASSWORD_ROOT}" | chpasswd -R ${TARGET}
arch-chroot ${TARGET} useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:${PASSWORD_ROOT}" | chpasswd -R ${TARGET}
btrfs subvolume create @home_${USERNAME}_nobackup
chattr +C @home_${USERNAME}_nobackup
chown 1000:1000 @home_${USERNAME}_nobackup
arch-chroot ${TARGET} sudo -u ${USERNAME} mkdir /home/${USERNAME}/nobackup
echo "${device_luks_device}  /home/${USERNAME}/nobackup  btrfs  rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@home_${USERNAME}_nobackup  0 0" >>${TARGET}/etc/fstab
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >${TARGET}/etc/sudoers.d/${USERNAME}

# Bootloader, SecureBoot
if ! ${BIOS} && ${SECUREBOOT}; then
    pacman -Sy --noconfirm efitools sbsigntools
    pacstrap -c ${TARGET} intel-ucode apparmor efitools sbsigntools
    arch-chroot ${TARGET} systemctl enable apparmor

    echo "cryptdevice=UUID=$(blkid -s UUID -o value ${DEVICE}2):${LUKS_DEVICE} root=${device_luks_device} rw rootflags=subvol=@ quiet sysrq_always_enabled=1 apparmor=1 security=apparmor acpi_enforce_resources=lax" >${TARGET}/etc/cmdline

    mkdir ${TARGET}/etc/secureboot
    cd ${TARGET}/etc/secureboot

    uuidgen --random >GUID.txt
    openssl req -newkey rsa:4096 -nodes -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Platform Key/" -out PK.crt
    openssl x509 -outform DER -in PK.crt -out PK.cer
    cert-to-efi-sig-list -g "$(<GUID.txt)" PK.crt PK.esl
    sign-efi-sig-list -g "$(<GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth

    sign-efi-sig-list -g "$(<GUID.txt)" -c PK.crt -k PK.key PK /dev/null rm_PK.auth

    openssl req -newkey rsa:4096 -nodes -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Key Exchange Key/" -out KEK.crt
    openssl x509 -outform DER -in KEK.crt -out KEK.cer
    cert-to-efi-sig-list -g "$(<GUID.txt)" KEK.crt KEK.esl
    sign-efi-sig-list -g "$(<GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth

    openssl req -newkey rsa:4096 -nodes -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=my Signature Database key/" -out db.crt
    openssl x509 -outform DER -in db.crt -out db.cer
    cert-to-efi-sig-list -g "$(<GUID.txt)" db.crt db.esl
    sign-efi-sig-list -g "$(<GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth

    arch-chroot ${TARGET} bootctl --path=/boot/efi install

    echo "timeout  5" >>${TARGET}/boot/efi/loader/loader.conf
    echo "editor   no" >>${TARGET}/boot/efi/loader/loader.conf

    cat ${TARGET}/boot/intel-ucode.img ${TARGET}/boot/initramfs-linux.img >${TARGET}/boot/ucode-initramfs-linux.img
    objcopy --add-section .osrel="${TARGET}/usr/lib/os-release" --change-section-vma .osrel=0x20000 --add-section .cmdline="${TARGET}/etc/cmdline" --change-section-vma .cmdline=0x30000 --add-section .splash="${TARGET}/usr/share/systemd/bootctl/splash-arch.bmp" --change-section-vma .splash=0x40000 --add-section .linux="${TARGET}/boot/vmlinuz-linux" --change-section-vma .linux=0x2000000 --add-section .initrd="${TARGET}/boot/ucode-initramfs-linux.img" --change-section-vma .initrd=0x3000000 "${TARGET}/usr/lib/systemd/boot/efi/linuxx64.efi.stub" "${TARGET}/boot/efi/EFI/Linux/linux.efi"

    sbsign --key ${TARGET}/etc/secureboot/db.key --cert ${TARGET}/etc/secureboot/db.crt --output ${TARGET}/boot/efi/EFI/systemd/systemd-bootx64.efi ${TARGET}/boot/efi/EFI/systemd/systemd-bootx64.efi
    sbsign --key ${TARGET}/etc/secureboot/db.key --cert ${TARGET}/etc/secureboot/db.crt --output ${TARGET}/boot/efi/EFI/BOOT/BOOTX64.EFI ${TARGET}/boot/efi/EFI/BOOT/BOOTX64.EFI
    sbsign --key ${TARGET}/etc/secureboot/db.key --cert ${TARGET}/etc/secureboot/db.crt --output ${TARGET}/boot/efi/EFI/Linux/linux.efi ${TARGET}/boot/efi/EFI/Linux/linux.efi

    mkdir ${TARGET}/boot/efi/tmp
    cp ${TARGET}/etc/secureboot/{*.cer,*.esl,*.auth} ${TARGET}/boot/efi/tmp/
    sbsign --key ${TARGET}/etc/secureboot/db.key --cert ${TARGET}/etc/secureboot/db.crt --output ${TARGET}/boot/efi/KeyTool-signed.efi ${TARGET}/usr/share/efitools/efi/KeyTool.efi
    echo "title KeyTool" >>${TARGET}/boot/efi/loader/entries/keytool.conf
    echo "efi   /KeyTool-signed.efi" >>${TARGET}/boot/efi/loader/entries/keytool.conf

    mkdir ${TARGET}/etc/pacman.d/hooks
    cat <<EOF >>${TARGET}/etc/pacman.d/hooks/96-systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl --path=/boot/efi update
EOF

    cat <<EOF >>${TARGET}/etc/pacman.d/hooks/97-intel-ucode.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = intel-ucode
Target = linux
Target = systemd

[Action]
Description = Create microcode include initramfs
When = PostTransaction
Exec = /usr/bin/sh -c "/usr/bin/cat /boot/intel-ucode.img /boot/initramfs-linux.img > /boot/ucode-initramfs-linux.img"
Depends = coreutils
EOF

    cat <<EOF >>${TARGET}/etc/pacman.d/hooks/98-unified-kernel-image.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = intel-ucode
Target = linux
Target = systemd

[Action]
Description = Create unified kernel image
When = PostTransaction
Exec = /usr/bin/objcopy --add-section .osrel="/usr/lib/os-release" --change-section-vma .osrel=0x20000 --add-section .cmdline="/etc/cmdline" --change-section-vma .cmdline=0x30000 --add-section .splash="/usr/share/systemd/bootctl/splash-arch.bmp" --change-section-vma .splash=0x40000 --add-section .linux="/boot/vmlinuz-linux" --change-section-vma .linux=0x2000000 --add-section .initrd="/boot/ucode-initramfs-linux.img" --change-section-vma .initrd=0x3000000 "/usr/lib/systemd/boot/efi/linuxx64.efi.stub" "/boot/efi/EFI/Linux/linux.efi"
Depends = binutils
EOF

    cat <<EOF >>${TARGET}/etc/pacman.d/hooks/99-secureboot.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = intel-ucode
Target = linux
Target = systemd

[Action]
Description = Signing Kernel for Secure Boot
When = PostTransaction
Exec = /usr/bin/sh -c "/usr/bin/find /boot/efi -type f \( -name 'linux.efi' -o -name 'systemd*' -o -name 'BOOTX64.EFI' \) -exec /usr/bin/sh -c 'if ! /usr/bin/sbverify --list {} 2>/dev/null | /usr/bin/grep -q \"signature certificates\"; then /usr/bin/sbsign --key /etc/secureboot/db.key --cert /etc/secureboot/db.crt --output {} {}; fi' \;"
Depends = sbsigntools
Depends = findutils
Depends = grep
EOF

    chmod +x ${TARGET}/etc/pacman.d/hooks/*

elif ${BIOS} && ! ${SECUREBOOT}; then
    echo "TODO"
fi
