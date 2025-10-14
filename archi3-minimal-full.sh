#!/bin/bash

cat > ~/.config/i3/config <<'EOF'
set $mod Mod4

bindsym $mod+t exec kitty

bindsym $mod+d exec rofi -show drun

bindsym Print exec flameshot gui
bindsym Shift+Print exec flameshot full -p ~/Pictures

bindsym $mod+q kill

bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right


bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right


bindsym $mod+f fullscreen toggle


bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Sair do i3?' -b 'Sim' 'i3-msg exit'"


bindsym XF86AudioRaiseVolume exec amixer -q set Master 5%+
bindsym XF86AudioLowerVolume exec amixer -q set Master 5%-
bindsym XF86AudioMute exec amixer -q set Master toggle


bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-


set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"

bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5


bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5

exec_always --no-startup-id nm-applet
exec_always --no-startup-id picom --config ~/.config/picom.conf &
exec_always --no-startup-id flameshot &
exec_always --no-startup-id feh --bg-fill ~/Pictures/Wallpapers/dark_wallpaper.jpg
EOF
echo "💡 Reinicie a sessão e entre no i3 para aplicar tudo."
