#!/bin/bash
# =======================================================
#  Configuração completa do i3wm - Arch Linux
#  Autor: aliendede1 (modificado por ChatGPT)
# =======================================================

echo "=== Atualizando o sistema ==="
sudo pacman -Syu --noconfirm

echo "=== Instalando pacotes essenciais ==="
sudo pacman -S --noconfirm \
  i3-wm i3status i3lock dmenu rofi \
  kitty \
  picom feh flameshot \
  papirus-icon-theme arc-gtk-theme \
  alsa-utils brightnessctl \
  xclip xdotool \
  polkit-gnome network-manager-applet

# -------------------------------------------------------
# CRIANDO CONFIG DO I3
# -------------------------------------------------------
mkdir -p ~/.config/i3

cat > ~/.config/i3/config <<'EOF'
# ============================
# CONFIG I3 - DARK THEME
# ============================

set $mod Mod4  # tecla Super (Win)

# Terminal
bindsym $mod+t exec kitty

# Menu de apps (rofi)
bindsym $mod+d exec rofi -show drun

# Print
bindsym Print exec flameshot gui
bindsym Shift+Print exec flameshot full -p ~/Pictures

# Fechar janela
bindsym $mod+q kill

# Mover foco
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Mover janelas
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# Tela cheia
bindsym $mod+f fullscreen toggle

# Restart / exit
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Sair do i3?' -b 'Sim' 'i3-msg exit'"

# Volume
bindsym XF86AudioRaiseVolume exec amixer -q set Master 5%+
bindsym XF86AudioLowerVolume exec amixer -q set Master 5%-
bindsym XF86AudioMute exec amixer -q set Master toggle

# Brilho
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

# Iniciar apps no login
exec_always --no-startup-id nm-applet
exec_always --no-startup-id picom --config ~/.config/picom.conf &
exec_always --no-startup-id flameshot &
exec_always --no-startup-id feh --bg-fill ~/Pictures/Wallpapers/dark_wallpaper.jpg

# Barra
bar {
    status_command i3status
    position top
    font pango:JetBrains Mono 10
    colors {
        background #1e1e2e
        statusline #cdd6f4
        separator  #89b4fa
        focused_workspace  #89b4fa #1e1e2e #ffffff
        inactive_workspace #313244 #1e1e2e #aaaaaa
    }
}
EOF

# -------------------------------------------------------
# CONFIG PICOM (TRANSPARÊNCIA)
# -------------------------------------------------------
mkdir -p ~/.config
cat > ~/.config/picom.conf <<'EOF'
backend = "glx";
vsync = true;
shadow = true;
shadow-radius = 10;
corner-radius = 8.0;
blur-method = "dual_kawase";
blur-strength = 5;
opacity-rule = ["90:class_g = 'kitty'"];
EOF

# -------------------------------------------------------
# WALLPAPER DARK
# -------------------------------------------------------
mkdir -p ~/Pictures/Wallpapers
wget -q -O ~/Pictures/Wallpapers/dark_wallpaper.jpg https://wallpapercave.com/wp/wp6676301.jpg

# -------------------------------------------------------
# TEMA GTK DARK
# -------------------------------------------------------
echo "=== Aplicando tema dark ==="
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme "Adwaita-dark" 2>/dev/null || true

# -------------------------------------------------------
# FINALIZAÇÃO
# -------------------------------------------------------
echo
echo "🌙 i3 configurado com sucesso!"
echo "✅ Terminal: Win + T"
echo "🎨 Menu: Win + D"
echo "📸 Print: Print / Shift + Print"
echo "🎧 Volume e brilho funcionando"
echo "💡 Reinicie a sessão e entre no i3 para aplicar tudo."
