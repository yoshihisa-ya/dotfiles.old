.DEFAULT_GOAL := help

SHELL = bash

PACKAGE_LIST := packages.txt
AUR_LIST     := aur.txt

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
	test -f ${HOME}/.vim/autoload/plug.vim || \
		curl -fLo ${HOME}/.vim/autoload/plug.vim \
		--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	test -d ${HOME}/.vim/plugin || \
		mkdir -p ${HOME}/.vim/plugin
	test -f /usr/share/vim/vimfiles/plugin/gtags.vim && \
		cp /usr/share/vim/vimfiles/plugin/gtags.vim ${HOME}/.vim/plugin/

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
	comm -23 <(pacman -Qeqn | sort) <(pacman -Qgq base base-devel | sort) | diff ${PACKAGE_LIST} - || :
	pacman -Qqem | diff ${AUR_LIST} - || :
