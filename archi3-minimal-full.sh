#!/bin/bash
# =======================================================
#  Script Completo de Instalação - Arch Linux
#  Autor: ChatGPT (by Andre)
#  Funções:
#   - Configura ambiente de programação completo
#   - Instala Yay (AUR)
#   - Instala linguagens: Java, Python, Lua, Node.js, C, C++
#   - Instala Flatpak + Flathub
#   - Instala Discord, Spotify, YT Music
#   - Instala ferramentas multimídia
#   - Configura SSH + UFW
#   - Aplica tema dark completo
# =======================================================

echo "=== Atualizando o sistema ==="
sudo pacman -Syu --noconfirm

echo "=== Instalando pacotes essenciais ==="
sudo pacman -S --noconfirm \
  base-devel \
  git \
  vim \
  curl \
  wget \
  unzip \
  zip \
  p7zip \
  htop \
  neofetch \
  ufw \
  openssh \
  flatpak \
  papirus-icon-theme \
  arc-gtk-theme \
  gnome-keyring

# -------------------------------------------------------
# INSTALAÇÃO DO YAY (AUR HELPER)
# -------------------------------------------------------
if ! command -v yay &>/dev/null; then
  echo "=== Instalando Yay (AUR helper) ==="
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "✅ Yay já está instalado."
fi

# -------------------------------------------------------
# SERVIÇOS DE SISTEMA
# -------------------------------------------------------
echo "=== Ativando e iniciando SSH ==="
sudo systemctl enable sshd
sudo systemctl start sshd

echo "=== Configurando firewall (UFW) ==="
sudo systemctl enable ufw
sudo ufw allow ssh
sudo ufw enable

# -------------------------------------------------------
# FLATPAK + FLATHUB
# -------------------------------------------------------
echo "=== Configurando Flathub ==="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "=== Instalando aplicativos Flatpak ==="
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub app.ytmdesktop.ytmdesktop

# -------------------------------------------------------
# LINGUAGENS E FERRAMENTAS DE PROGRAMAÇÃO
# -------------------------------------------------------
echo "=== Instalando linguagens e compiladores ==="
sudo pacman -S --noconfirm \
  python python-pip \
  lua luarocks \
  nodejs npm \
  jdk17-openjdk \
  clang gcc gdb make cmake \
  pkgconf

echo "=== Configurando variáveis do Java ==="
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' | sudo tee /etc/profile.d/java.sh
source /etc/profile.d/java.sh

# -------------------------------------------------------
# IDEs E EDITORES (opcional)
# -------------------------------------------------------
echo "=== Instalando VS Code (AUR) ==="
yay -S --noconfirm visual-studio-code-bin

# -------------------------------------------------------
# FERRAMENTAS MULTIMÍDIA
# -------------------------------------------------------
echo "=== Instalando OBS, GIMP, Kdenlive, VLC, etc. ==="
sudo pacman -S --noconfirm \
  obs-studio \
  vlc \
  gimp \
  kdenlive \
  ffmpeg \
  audacity \
  simplescreenrecorder

# -------------------------------------------------------
# TEMA DARK
# -------------------------------------------------------
echo "=== Aplicando tema dark ==="
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-theme "Adwaita-dark" 2>/dev/null || true
fi

mkdir -p ~/Pictures/Wallpapers
wget -q -O ~/Pictures/Wallpapers/dark_wallpaper.jpg https://wallpapercave.com/wp/wp6676301.jpg
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/dark_wallpaper.jpg"
fi

# -------------------------------------------------------
# FINALIZAÇÃO
# -------------------------------------------------------
echo "=== Limpando pacotes e cache ==="
sudo pacman -Sc --noconfirm

echo
echo "🌙 Tudo pronto!"
echo "✅ Sistema completo para programação e multimídia instalado."
echo "🧰 Linguagens: Java, Python, Lua, Node.js, C, C++"
echo "🎨 Tema dark aplicado e apps como Discord, Spotify e OBS instalados."
echo "💡 Reinicie o sistema para aplicar todas as alterações."
