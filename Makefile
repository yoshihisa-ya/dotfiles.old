.DEFAULT_GOAL := help

SHELL = bash

HOSTNAME := $(shell hostname -f)

PACKAGE_LIST := ~/Sync/dotfiles/list/$(HOSTNAME)_packages.txt
AUR_LIST     := ~/Sync/dotfiles/list/$(HOSTNAME)_aur.txt

EXCLUSIONS := .git .gitignore
DOTFILES   := $(filter-out $(EXCLUSIONS), $(wildcard .??*))

YAY_INSTALL := yay -S --needed --noconfirm

define SNAPPERBOOT
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Depends = rsync
Description = Backing up /boot...
When = PostTransaction
Exec = /usr/bin/rsync -a --delete /boot /.bootbackup
endef
export SNAPPERBOOT

.PHONY: help
help: ### Help
	@echo "Please use 'make <target>' where <target> is one of"
	@grep -E '^[a-zA-Z_-]+:.*?### .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?### "}; {printf "  \033[1;34m%-15s\033[0m-- %s\n", $$1, $$2}'
	@echo ""
	@echo "Example:"
	@echo "  make pre"
	@echo "  # Setting syncthing"
	@echo "  ## sudo systemctl enable --now syncthing@${USER}.service"
	@echo "  ## http://localhost:8384/"
	@echo "  make common"
	@echo "  make snapper"
	@echo "  make (intel-gpu|amd-gpu|spice) # for desktop"
	@echo "  make [termianl|desktop]"

.PHONY: pre
pre: yay syncthing ### Pre Deploy Arch Linux

.PHONY: dotfiles
dotfiles: ### Install dotfiles
	@$(foreach dotfile, $(DOTFILES), ln -sfnv $(abspath $(dotfile)) $(HOME)/$(dotfile);)
	source ~/.bash_profile
	test -f ${HOME}/sync/dotfiles/.gitconfig.$(HOSTNAME) && \
		ln -sfnv ${HOME}/sync/dotfiles/.gitconfig.$(HOSTNAME) ${HOME}/.gitconfig || :
	test -d ${HOME}/.obj || mkdir -m 755 ${HOME}/.obj

.PHONY: list
list: ### Make installed package list
	comm -23 <(pacman -Qeqn | sort) <(pacman -Qgq base-devel | sort) > ${PACKAGE_LIST}
	pacman -Qqem > ${AUR_LIST}
	@echo
	@echo make package list done.

.PHONY: diff
diff: ### Diff installed-packages, package-list
	@comm -23 <(pacman -Qeqn | sort) <(pacman -Qgq base-devel | sort) | diff ${PACKAGE_LIST} - || :
	@pacman -Qqem | diff ${AUR_LIST} - || :

.PHONY: yay
yay: ### Install yay
	# TODO: yay が存在する場合は即exitする。
	sudo pacman -S --needed --noconfirm git go
	cd $(shell mktemp -d); git clone https://aur.archlinux.org/yay.git; cd yay; type yay || makepkg -si --noconfirm

.PHONY: syncthing
syncthing: ### Install syncthing
	type syncthing || $(YAY_INSTALL) syncthing
	@echo "Plese syncthing setting"

.PHONY: terminal # For CLI Environment
terminal: common mail rss terminal-packages ### Install packages For CLI environment
	$(YAY_INSTALL) neovim
	test -f ${HOME}/.local/share/nvim/site/autoload/plug.vim || \
		curl -fLo ${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	test -d ${HOME}/.config || mkdir -m 755 ${HOME}/.config
	test -d ${HOME}/.config/nvim || mkdir -m 750 ${HOME}/.config/nvim
	ln -sfnv $(abspath config/nvim/init.vim) ${HOME}/.config/nvim/init.vim

.PHONY: common
common:
	sudo sed -i '/^#ParallelDownloads =/s/#//' /etc/pacman.conf
	$(YAY_INSTALL) dmidecode man-db man-pages usbutils cpio mlocate cronie lsof rsync tmux whois tcpdump traceroute imagemagick wget dnsutils nmap linux-headers linux-docs nfs-utils strace gdb perf jq sysstat crash unzip ethtool lm_sensors nvme-cli
	sudo systemctl enable --now cronie.service
	sudo sed -i -e '/^HISTORY=/s/7/365/' -e 's/^SADC_OPTIONS=" *"/SADC_OPTIONS="-S XALL"/' /etc/conf.d/sysstat
	sudo systemctl enable --now sysstat.service

.PHONY: mail
mail: ### Install mail client
	$(YAY_INSTALL) isync getmail6 neomutt notmuch procmail

.PHONY: rss
rss: ### Install rss client
	$(YAY_INSTALL) newsboat

.PHONY: terminal-packages
terminal-packages: ### Install terminal-packages
	$(YAY_INSTALL) pass pwgen dateutils dialog moreutils ranger ffmpegthumbnailer iftop rpm-tools bc bash-completion fzf global ghq peco shfmt screen wireshark-cli iperf3 porg cowsay hugo marp-cli

.PHONY: qemu-desktop
qemu-desktop: ### Install qemu-desktop packages
	$(YAY_INSTALL) qemu-desktop

.PHONY: qemu-base
qemu-base: ### Install qemu-base packages
	$(YAY_INSTALL) qemu-base

.PHONY: desktop # For GUI Environment
desktop: terminal intel-gpu xorg fonts wm input-methods desktop-packages firefox libvirt snap-apps qemu-desktop ### Install desktop packages For GUI environment

.PHONY: intel-gpu
intel-gpu: ### Install intel iGPU tools
	$(YAY_INSTALL) mesa intel-gpu-tools intel-media-driver libva-utils

.PHONY: xorg
xorg: ### Install X Window System
	$(YAY_INSTALL) xorg-server xorg-xinit xorg-xwininfo xorg-xrandr xterm xclip arandr
	$(YAY_INSTALL) pipewire-pulse pavucontrol

.PHONY: fonts
fonts: ### Install fonts
	$(YAY_INSTALL) ttf-ricty xorg-mkfontscale ttf-monapo ttf-vlgothic otf-ipafont otf-ipaexfont otf-ipamjfont ttf-dejavu ttf-sazanami ttf-hanazono

.PHONY: wm
wm: mpd ### Install Window Manager
	$(YAY_INSTALL) network-manager-applet i3-wm i3lock xautolock rofi papirus-icon-theme picom feh polybar siji-ng playerctl
	# i3
	test -d ${HOME}/.config/i3 || mkdir -m 750 ${HOME}/.config/i3
	ln -sfnv $(abspath config/i3/config) ${HOME}/.config/i3/config
	# polybar
	ln -sfnv $(abspath config/polybar) ${HOME}/.config/polybar
	### TODO: multiple monitor setting
	### TODO: suspend lock setting
	# rofi
	test -d ${HOME}/.config/rofi || mkdir -m 755 ${HOME}/.config/rofi
	ln -sfnv $(abspath config/rofi/config.rasi) ${HOME}/.config/rofi/config.rasi

.PHONY: mpd
mpd: ### Install mpd
	$(YAY_INSTALL) mpd mpc
	test -d ${HOME}/.config/mpd || mkdir -m 755 ${HOME}/.config/mpd
	test -d ${HOME}/.config/mpd/playlists || mkdir -m 755 ${HOME}/.config/mpd/playlists
	ln -sfnv $(abspath config/mpd/mpd.conf) ${HOME}/.config/mpd/mpd.conf

.PHONY: input-methods
input-methods: ### Install Input Method
	$(YAY_INSTALL) ibus ibus-skk skk-jisyo

.PHONY: desktop-packages
desktop-packages: ### Install desktop-packages
	$(YAY_INSTALL) sxiv yt-dlp mpv gimp obs-studio remmina freerdp wireshark-qt discord slack-desktop ticktick
	$(YAY_INSTALL) solaar redshift ddcutil # for metal machine
	# TODO: mpv rcfile

.PHONY: firefox
firefox: psd ### Install Firefox
	$(YAY_INSTALL) firefox firefox-i18n-ja

.PHONY: psd
psd: ### Install psd
	$(YAY_INSTALL) profile-sync-daemon
	# TODO: psd setting

.PHONY: libvirt
libvirt: qemu-desktop ### Install libvirt packages
	$(YAY_INSTALL) libvirt virt-manager bridge-utils dmidecode iptables-nft dnsmasq
	sudo systemctl enable --now libvirtd
	sudo usermod -aG libvirt yoshihisa # TODO: ユーザ名固定しない

.PHONY: snap
snap: ### Install snapd packages
	$(YAY_INSTALL) snapd
	sudo systemctl enable --now apparmor.service
	sudo systemctl enable --now snapd.apparmor.service
	sudo systemctl enable --now snapd.socket

.PHONY: snap-apps
snap-apps: snap ### Install snap application packages
	type joplin-desktop || sudo snap install joplin-desktop

.PHONY: snapper
snapper: ### Setting snapper
	$(YAY_INSTALL) snapper snap-pac
	grep -q '.snapshots' /etc/updatedb.conf || sudo sed -i '/^PRUNENAMES/s/"$$/ .snapshots"/' /etc/updatedb.conf
	sudo snapper -c root get-config > /dev/null || sudo snapper -c root create-config /
	sudo btrfs subvolume show /.snapshots && sudo btrfs subvolume delete /.snapshots || :
	sudo mkdir -p /.snapshots
	sudo mount /mnt
	cd /mnt && sudo btrfs subvolume create @snapshots || :
	grep -q snapshots /etc/fstab || grep 'subvol=@ ' /etc/fstab | sed -e 's/\/ /\/.snapshots/' -e 's/@/@snapshots/' | sudo tee -a /etc/fstab
	sudo umount /mnt
	sudo systemctl daemon-reload
	sudo mount -a
	sudo chmod 750 /.snapshots
	sudo snapper -c root set-config "TIMELINE_LIMIT_DAILY=7"
	sudo snapper -c root set-config "TIMELINE_LIMIT_HOURLY=10"
	sudo snapper -c root set-config "TIMELINE_LIMIT_MONTHLY=0"
	sudo snapper -c root set-config "TIMELINE_LIMIT_WEEKLY=0"
	sudo snapper -c root set-config "TIMELINE_LIMIT_YEARLY=0"
	sudo snapper -c home get-config > /dev/null || sudo snapper -c home create-config /home
	echo "$$SNAPPERBOOT" | sudo tee /etc/pacman.d/hooks/aa-bootbackup.hook
	sudo chmod +x /etc/pacman.d/hooks/aa-bootbackup.hook

.PHONY: backuppc
backuppc: ### Setting backuppc
	# TODO: backuppc setting

.PHONY: zsh
zsh:
	$(YAY_INSTALL) zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions pkgfile

.PHONY: stress
stress:
	$(YAY_INSTALL) stress
