#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then

    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then

    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx &
xscreensaver -nosplash &
cat $HOME/.config/i3/config.base >$HOME/.config/i3/config
if [ -f "$HOME/sync/dotfiles/config/i3/config.$HOSTNAME" ]; then
    cat $HOME/sync/dotfiles/config/i3/config.$HOSTNAME >>$HOME/.config/i3/config
fi
[ ! -s ~/.mpd/pid ] && type mpd >/dev/null 2>&1 && mpd
type xbindkeys >/dev/null 2>&1 && xbindkeys &
exec i3
