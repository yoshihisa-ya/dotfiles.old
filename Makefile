.DEFAULT_GOAL := help

SHELL = bash

HOSTNAME := $(shell hostname)

PACKAGE_LIST := ~/sync/dotfiles/list/$(HOSTNAME)_packages.txt
AUR_LIST     := ~/sync/dotfiles/list/$(HOSTNAME)_aur.txt

EXCLUSIONS := .git .gitignore
DOTFILES   := $(filter-out $(EXCLUSIONS), $(wildcard .??*))

.PHONY: help
help: ### Help
	@echo "Please use 'make <target>' where <target> is one of"
	@grep -E '^[a-zA-Z_-]+:.*?### .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?### "}; {printf "  \033[1;34m%-15s\033[0m-- %s\n", $$1, $$2}'

.PHONY: deploy
deploy: install dotfiles ### Deploy ArchLinux

.PHONY: dotfiles
dotfiles: ### Install dotfiles
	@$(foreach dotfile, $(DOTFILES), ln -sfnv $(abspath $(dotfile)) $(HOME)/$(dotfile);)
	test -f ${HOME}/sync/dotfiles/.gitconfig.$(HOSTNAME) && \
		ln -sfnv ${HOME}/sync/dotfiles/.gitconfig.$(HOSTNAME) ${HOME}/.gitconfig || :
	test -f ${HOME}/.vim/autoload/plug.vim || \
		curl -fLo ${HOME}/.vim/autoload/plug.vim \
		--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	test -d ${HOME}/.vim/plugin || \
		mkdir -p ${HOME}/.vim/plugin
	test -f /usr/share/vim/vimfiles/plugin/gtags.vim && \
		cp /usr/share/vim/vimfiles/plugin/gtags.vim ${HOME}/.vim/plugin/
	test -d ${HOME}/.config || mkdir -m 755 ${HOME}/.config
	test -d ${HOME}/.config/i3 || mkdir -m 750 ${HOME}/.config/i3
	test -d ${HOME}/.config/fcitx || mkdir -m 750 ${HOME}/.config/fcitx
	test -d ${HOME}/.config/fcitx/conf || mkdir -m 700 ${HOME}/.config/fcitx/conf
	ln -sfnv $(abspath config/i3/config.base) ${HOME}/.config/i3/config.base
	ln -sfnv $(abspath config/fcitx/config) ${HOME}/.config/fcitx/config
	ln -sfnv $(abspath config/fcitx/conf/fcitx-keyboard.config) ${HOME}/.config/fcitx/conf/fcitx-keyboard.config
	ln -sfnv $(abspath config/fcitx/conf/fcitx-classic-ui.config) ${HOME}/.config/fcitx/conf/fcitx-classic-ui.config

.PHONY: install
install: ### Install packages
	sudo pacman -S --needed - < ${PACKAGE_LIST}
	cat ${AUR_LIST} | xargs -n 1 yay -S --noconfirm --needed

.PHONY: list
list: ### Make installed package list
	comm -23 <(pacman -Qeqn | sort) <(pacman -Qgq base base-devel | sort) > ${PACKAGE_LIST}
	pacman -Qqem > ${AUR_LIST}
	@echo
	@echo make package list done.

.PHONY: diff
diff: ### Diff installed-packages, package-list
	@comm -23 <(pacman -Qeqn | sort) <(pacman -Qgq base base-devel | sort) | diff ${PACKAGE_LIST} - || :
	@pacman -Qqem | diff ${AUR_LIST} - || :

.PHONY: shfmt
shfmt: ### Install shfmt
	cd $(shell mktemp -d); go mod init tmp; go get mvdan.cc/sh/cmd/shfmt

.PHONY: yay
yay: ### Install yay
	sudo pacman -S --needed --noconfirm git go
	cd $(shell mktemp -d); git clone https://aur.archlinux.org/yay.git; cd yay; type yay || makepkg -si --noconfirm

.PHONY: unison
unison: ### Install unison
	sudo pacman -S --needed --noconfirm git go
	type unison || sudo pacman -S --needed --noconfirm unison
