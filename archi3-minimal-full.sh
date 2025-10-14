#!/bin/bash
# =======================================================
#  Configuração completa do i3wm - Arch Linux
#  Autor: ChatGPT (by Andre)
#  Recursos:
#    - Tema dark e transparência
#    - Print com Flameshot
#    - Terminal com Win + T
#    - Atalhos básicos
# =======================================================

echo "=== Atualizando o sistema ==="
sudo pacman -Syu --noconfirm

echo "=== Instalando pacotes essenciais ==="
sudo pacman -S --noconfirm \
  i3-wm i3status i3lock dmenu rofi \
  picom feh flameshot \
  kitty \
  papirus-icon-theme \
  arc-gtk-theme \
  alsa-utils brightnessctl \
  xclip xdotool

# -------------------------------------------------------
# CRIANDO CONFIGURAÇÃO DO I3
# -------------------------------------------------------
mkdir -p ~/.config/i3

cat > ~/.config/i3/config <<'EOF'
# ============================
# CONFIG I3 CUSTOM DARK
# ============================

# Mod key (Win)
set $mod Mod4

# Terminal
bindsym $mod+t exec kitty

# Fechar janela
bindsym $mod+q kill

# Mudar foco
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Trocar janelas
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# Tela cheia
bindsym $mod+f fullscreen toggle

# Rofi launcher
bindsym $mod+d exec rofi -show drun

# Printscreen
bindsym Print exec flameshot gui
bindsym Shift+Print exec flameshot full -p ~/Pictures

# Reiniciar/fechar i3
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Sair do i3?' -b 'Sim' 'i3-msg exit'"

# Ajuste de volume
bindsym XF86AudioRaiseVolume exec amixer -q set Master 5%+
bindsym XF86AudioLowerVolume exec amixer -q set Master 5%-
bindsym XF86AudioMute exec amixer -q set Master toggle

# Brilho
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

# Barra de status
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

# Picom (transparência)
exec_always --no-startup-id picom --config ~/.config/picom.conf &

# Papel de parede
exec_always --no-startup-id feh --bg-fill ~/Pictures/Wallpapers/dark_wallpaper.jpg
EOF

# -------------------------------------------------------
# CONFIGURAÇÃO DO PICOM (TRANSPARÊNCIA)
# -------------------------------------------------------
mkdir -p ~/.config
cat > ~/.config/picom.conf <<'EOF'
backend = "glx";
vsync = true;
shadow = true;
shadow-radius = 10;
corner-radius = 8.0;
opacity-rule = ["90:class_g = 'kitty'"];
EOF

# -------------------------------------------------------
# PAPEL DE PAREDE DARK
# -------------------------------------------------------
mkdir -p ~/Pictures/Wallpapers
wget -q -O ~/Pictures/Wallpapers/dark_wallpaper.jpg https://wallpapercave.com/wp/wp6676301.jpg

# -------------------------------------------------------
# FINALIZAÇÃO
# -------------------------------------------------------
echo
echo "🌙 i3 configurado com sucesso!"
echo "✅ Terminal: Win + T"
echo "📸 Printscreen: Print ou Shift+Print"
echo "🎨 Tema dark aplicado com transparência."
echo
echo "💡 Faça login no i3 para ver as mudanças."
