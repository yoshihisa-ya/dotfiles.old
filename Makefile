.DEFAULT_GOAL := help

PACKAGE_LIST := packages.txt
AUR_LIST     := aur.txt

.PHONY: help
help: ### Help
	@echo "Please use 'make <target>' where <target> is one of"
	@grep -E '^[a-zA-Z_-]+:.*?### .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?### "}; {printf "  \033[1;34m%-15s\033[0m-- %s\n", $$1, $$2}'

.PHONY: deploy
deploy: packages dotfiles ### Deploy ArchLinux

.PHONY: dotfiles
dotfiles: ### Install dotfiles
	ln -fsn ${PWD}/.vimrc ${HOME}/.vimrc
	ln -fsn ${PWD}/.bashrc ${HOME}/.bashrc
	ln -fsn ${PWD}/.bash_profile ${HOME}/.bash_profile
	ln -fsn ${PWD}/.tmux.conf ${HOME}/.tmux.conf
	test -f ${HOME}/.vim/autoload/plug.vim || \
		curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	test -d ${HOME}/.vim/plugin || \
		mkdir -p ${HOME}/.vim/plugin
	test -f /usr/share/vim/vimfiles/plugin/gtags.vim && \
		cp /usr/share/vim/vimfiles/plugin/gtags.vim ${HOME}/.vim/plugin/

.PHONY: packages
packages: ### Install packages
	sudo pacman -S --needed - < ${PACKAGE_LIST}
	cat ${AUR_LIST} | xargs -n 1 yay -S --noconfirm --needed

.PHONY: backup
backup: ### Backup installed package to list
	pacman -Qqen > ${PACKAGE_LIST}
	pacman -Qqem > ${AUR_LIST}
	@echo
	@echo package list backup done.

.PHONY: diff
diff: ### Diff installed-packages, package-list
	pacman -Qqen | diff ${PACKAGE_LIST} -
	pacman -Qqem | diff ${AUR_LIST} -
