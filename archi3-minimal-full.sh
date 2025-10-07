#!/usr/bin/env bash
set -euo pipefail

# install-hamachi-debian.sh
# Uso: sudo ./install-hamachi-debian.sh
# Script para Debian/Ubuntu: detecta arquitetura, baixa .deb do Hamachi e instala.

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "==> Verificando privilégio de root..."
if [ "$EUID" -ne 0 ]; then
  echo "Este script deve ser executado como root (use sudo)." >&2
  exit 1
fi

echo "==> Detectando arquitetura..."
ARCH=$(dpkg --print-architecture || true)
case "$ARCH" in
  amd64|x86_64) PKG_ARCH="amd64" ;;
  i386|i486|i686) PKG_ARCH="i386" ;;
  armhf|armv7l) PKG_ARCH="armhf" ;;
  arm64|aarch64) PKG_ARCH="armhf" ;; # hamachi historically has armhf builds; may not exist for arm64
  *) PKG_ARCH="amd64" ;; # fallback
esac
echo "Arquitetura detectada: $ARCH -> usando pacote: $PKG_ARCH"

echo "==> Instalando dependências (apt update poderá pedir algum tempo)..."
apt-get update -y
# lsb-core pode ser necessário em algumas versões; tentamos instalar pacotes úteis
DEPS=(wget curl ca-certificates lsb-release)
# lsb-core package exists on some distros; try instalar sem falhar.
apt-get install -y "${DEPS[@]}" || true

echo "==> Tentando localizar o .deb oficial do Hamachi..."
HTMLFILE="$TMPDIR/vpn_net_linux.html"
curl -fsSL "https://vpn.net/linux" -o "$HTMLFILE" || true

# Procura por links para logmein-hamachi_...deb
DL_URL=$(grep -oE 'https?://[^"]*logmein-hamachi[^"]*\.deb' "$HTMLFILE" | head -n1 || true)

if [ -z "$DL_URL" ]; then
  echo "Não foi possível extrair link direto do vpn.net/linux. Usando fallback conhecido..."
  # fallback - versão conhecida (pode mudar com o tempo). Se quiser forçar outra versão, edite aqui.
  DL_URL="https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_amd64.deb"
  # Ajuste se a arquitetura for i386 ou armhf:
  if [ "$PKG_ARCH" = "i386" ]; then
    DL_URL="https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_i386.deb"
  elif [ "$PKG_ARCH" = "armhf" ]; then
    # Não há garantia de versão ARM; mantenha fallback genérico (pode falhar se não houver build armhf).
    DL_URL="https://secure.logmein.com/labs/logmein-hamachi_2.1.0.119-1_armhf.deb"
  fi
fi

echo "URL detectada: $DL_URL"
PKGFILE="$TMPDIR/hamachi.deb"

echo "==> Baixando pacote..."
if ! wget -q -O "$PKGFILE" "$DL_URL"; then
  echo "Erro ao baixar $DL_URL" >&2
  exit 2
fi

echo "==> Instalando pacote .deb..."
# instalar o .deb (dpkg pode deixar dependências pendentes)
dpkg -i "$PKGFILE" || true

echo "==> Corrigindo dependências (apt -f install)..."
apt-get install -y -f

# Tentar habilitar e iniciar o serviço de várias maneiras (systemd ou init.d)
echo "==> Tentando iniciar/ativar o serviço do Hamachi..."
if systemctl --version >/dev/null 2>&1; then
  # se existir unidade systemd criada como LSB wrapper, enable/start
  if systemctl list-units --type=service --all | grep -qi logmein-hamachi; then
    systemctl daemon-reload || true
    systemctl enable --now logmein-hamachi.service || true
  else
    # tentar via script SysV
    if [ -x /etc/init.d/logmein-hamachi ]; then
      /etc/init.d/logmein-hamachi restart || /etc/init.d/logmein-hamachi start || true
    fi
  fi
else
  if [ -x /etc/init.d/logmein-hamachi ]; then
    /etc/init.d/logmein-hamachi restart || /etc/init.d/logmein-hamachi start || true
  fi
fi

echo "==> Verificando se o binário 'hamachi' está disponível..."
if ! command -v hamachi >/dev/null 2>&1; then
  echo "Instalação concluída, mas binário 'hamachi' não foi encontrado no PATH." >&2
  echo "Verifique o conteúdo do pacote e logs." >&2
  exit 3
fi

echo
echo "Instalação concluída com sucesso (ou parcialmente). Próximos passos:"
echo "  # Para logar no seu account LogMeIn:"
echo "  sudo hamachi login"
echo "  # Para anexar esse cliente ao seu LogMeIn ID (email):"
echo "  sudo hamachi attach seu-email@exemplo.com"
echo "  # Para criar/entrar em rede:"
echo "  sudo hamachi create MinhaRede senhaDaRede   # (cria rede)"
echo "  sudo hamachi join ID-da-rede senhaDaRede    # (entra em rede existente)"
echo
echo "Comandos úteis de status:"
echo "  sudo hamachi                       # mostra status"
echo "  sudo hamachi list                  # lista peers na rede"
echo
echo "Se o serviço não estiver rodando, tente inspecionar logs via journalctl ou /var/log/syslog."
echo
echo "Referências: página oficial de downloads e instruções de instalação da LogMeIn Hamachi."
echo " - https://vpn.net/linux (página de downloads)."
echo " - instruções oficiais: https://support.logmein.com (ex.: instalar via dpkg/wget)."
exit 0
