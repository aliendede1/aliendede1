#!/bin/bash
# Instalação completa e bonita do i3wm (base Archi3)

cd ~/Archi3/installation || exit

for script in \
020-install-fastest-arch-mirrors-v1.sh \
030-install-xorg-intel.sh \
050-install-i3wm-core-v1.sh \
100-install-core-software-v1.sh \
120-install-sound-v1.sh \
130-install-network-v1.sh \
200-install-extra-software-v1.sh \
300-install-themes-icons-cursors-conky-v1.sh \
600-install-personal-settings-folders-v1.sh \
690-install-personal-settings-i3-configuration-v1.sh \
700-firefox-for-dark-themes-settings-v1.sh
do
  echo "--------------------------------------"
  echo "Executando $script..."
  echo "--------------------------------------"
  chmod +x "$script"
  ./"$script"
done

echo "======================================"
echo "Tudo pronto! Agora digite 'startx' para entrar no i3."
echo "======================================"
