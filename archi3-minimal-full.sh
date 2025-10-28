#!/bin/bash
# ==============================================
# 🚀 Script de configuração automática do XFCE4 no Void Linux
# Feito por ChatGPT — otimizado pra leveza e tema escuro
# ==============================================

# --- Verificação de root ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ Execute como root (use sudo ou entre como root)"
    exit 1
fi

echo "🔧 Atualizando sistema..."
xbps-install -Su -y

echo "💻 Instalando XFCE4 + extras..."
xbps-install -S -y xfce4 xfce4-goodies gvfs gvfs-smb gvfs-mtp thunar-volman \
network-manager-applet pavucontrol alsa-utils pulseaudio lightdm lightdm-gtk3-greeter

echo "🔌 Ativando serviços essenciais..."
for svc in dbus elogind polkitd lightdm NetworkManager; do
    ln -sf /etc/sv/$svc /var/service/
done

echo "🎨 Instalando temas escuros e ícones..."
xbps-install -S -y arc-theme papirus-icon-theme xfce4-terminal

echo "⚙️ Configurando tema escuro padrão..."
mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Noto Sans 10"/>
  </property>
</channel>
EOF

echo "🔉 Habilitando som e automount..."
ln -sf /etc/sv/alsa /var/service/ 2>/dev/null || true
ln -sf /etc/sv/udisksd /var/service/ 2>/dev/null || true
ln -sf /etc/sv/upower /var/service/ 2>/dev/null || true

echo "🧹 Limpando pacotes antigos..."
xbps-remove -O -y

echo "✅ Instalação completa!"
echo "Reinicie o sistema com: sudo reboot"
echo "Na próxima inicialização, entre no XFCE4 🎉"
