#!/bin/bash
# =========================================================
# Script UNIVERSAL de configuração de VPS
# Suporta: Debian, Ubuntu, Fedora, Arch, Void, Alpine
# Instala linguagens, servidores, bancos, Docker, VPNs, Vim, C/C++
# Pergunta se deseja criar usuário com sudo
# =========================================================

echo "=========================================="
echo "Bem-vindo ao configurador de VPS"
echo "=========================================="

# ===========================
# Detecta distro e gerenciador
# ===========================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Não foi possível detectar a distro."
    exit 1
fi

case "$DISTRO" in
    debian|ubuntu)
        PKG_UPDATE="apt update -y && apt upgrade -y"
        PKG_INSTALL="apt install -y"
        ;;
    fedora)
        PKG_UPDATE="dnf update -y"
        PKG_INSTALL="dnf install -y"
        ;;
    arch)
        PKG_UPDATE="pacman -Syu --noconfirm"
        PKG_INSTALL="pacman -S --noconfirm"
        ;;
    void)
        PKG_UPDATE="xbps-install -Suv"
        PKG_INSTALL="xbps-install -Sy"
        ;;
    alpine)
        PKG_UPDATE="apk update && apk upgrade"
        PKG_INSTALL="apk add --no-cache"
        ;;
    *)
        echo "Distro não suportada"
        exit 1
        ;;
esac

# ===========================
# Pergunta se quer criar usuário
# ===========================
read -p "Deseja criar um usuário com sudo? (s/n): " CREATE_USER
if [[ "$CREATE_USER" =~ ^[Ss]$ ]]; then
    read -p "Digite o nome do usuário que deseja criar: " NEWUSER
    case "$DISTRO" in
        debian|ubuntu)
            adduser $NEWUSER
            usermod -aG sudo $NEWUSER
            ;;
        fedora)
            adduser $NEWUSER
            usermod -aG wheel $NEWUSER
            ;;
        arch)
            useradd -m -G wheel $NEWUSER
            ;;
        void)
            useradd -m -G wheel $NEWUSER
            ;;
        alpine)
            adduser -D $NEWUSER
            echo "$NEWUSER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
            ;;
    esac
    echo "Usuário $NEWUSER criado com privilégios sudo."
fi

# ===========================
# Atualiza pacotes
# ===========================
echo "Atualizando pacotes..."
eval $PKG_UPDATE

# ===========================
# Instala ferramentas básicas
# ===========================
echo "Instalando ferramentas básicas..."
TOOLS="bash curl wget git htop tmux vim unzip zip sudo build-essential cmake make g++"
case "$DISTRO" in
    arch)
        TOOLS="base-devel git vim wget curl htop tmux unzip zip sudo"
        ;;
    fedora)
        TOOLS="bash curl wget git htop tmux vim unzip zip sudo make gcc gcc-c++ cmake"
        ;;
    void)
        TOOLS="bash curl wget git htop tmux vim unzip zip sudo gcc gcc-c++ make cmake"
        ;;
    alpine)
        TOOLS="bash curl wget git htop tmux vim unzip zip sudo shadow build-base cmake make g++"
        ;;
esac
eval $PKG_INSTALL $TOOLS

# ===========================
# Instala linguagens
# ===========================
echo "Instalando linguagens..."

# Python
case "$DISTRO" in
    debian|ubuntu|void)
        eval $PKG_INSTALL python3 python3-pip python3-dev
        ;;
    fedora)
        eval $PKG_INSTALL python3 python3-pip python3-devel
        ;;
    arch)
        eval $PKG_INSTALL python python-pip python-devel
        ;;
    alpine)
        eval $PKG_INSTALL python3 py3-pip python3-dev
        ;;
esac
pip3 install --upgrade pip setuptools wheel virtualenv

# Node.js
eval $PKG_INSTALL nodejs npm

# Java (OpenJDK 17)
case "$DISTRO" in
    debian|ubuntu)
        eval $PKG_INSTALL openjdk-17-jdk
        ;;
    fedora)
        eval $PKG_INSTALL java-17-openjdk-devel
        ;;
    arch)
        eval $PKG_INSTALL jdk17-openjdk
        ;;
    void)
        eval $PKG_INSTALL openjdk-17
        ;;
    alpine)
        eval $PKG_INSTALL openjdk17
        ;;
esac

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# PHP
eval $PKG_INSTALL php php-cli php-mbstring php-curl php-json php-openssl php-phar php-dev

# Go
eval $PKG_INSTALL go

# ===========================
# Instala servidores
# ===========================
echo "Instalando servidores web..."
case "$DISTRO" in
    debian|ubuntu|void|alpine)
        eval $PKG_INSTALL nginx apache2 apache2-utils
        ;;
    fedora)
        eval $PKG_INSTALL nginx httpd httpd-tools
        ;;
    arch)
        eval $PKG_INSTALL nginx apache
        ;;
esac

# ===========================
# Instala bancos de dados
# ===========================
echo "Instalando bancos de dados..."
eval $PKG_INSTALL mariadb mariadb-client redis
# Inicializa serviços (systemd)
for svc in mariadb redis nginx apache2; do
    if command -v systemctl >/dev/null 2>&1; then
        systemctl enable $svc
        systemctl start $svc
    fi
done

# ===========================
# Instala Docker
# ===========================
echo "Instalando Docker..."
eval $PKG_INSTALL docker docker-compose
if command -v systemctl >/dev/null 2>&1; then
    systemctl enable docker
    systemctl start docker
fi

# ===========================
# Instala Hamachi (apenas Alpine e Debian/Ubuntu simplificado)
# ===========================
echo "Instalando Hamachi..."
if [[ "$DISTRO" == "alpine" ]]; then
    eval $PKG_INSTALL openvpn lsb-core
    wget https://www.vpn.net/installers/logmein-hamachi-2.1.0.203-alpine.tgz -O /tmp/hamachi.tgz
    tar -xzf /tmp/hamachi.tgz -C /opt/
    chmod +x /opt/logmein-hamachi-2.1.0.203/hamachi
    ln -s /opt/logmein-hamachi-2.1.0.203/hamachi /usr/local/bin/hamachi
else
    echo "Para outras distros, instale Hamachi manualmente."
fi

# ===========================
# Instala ZeroTier
# ===========================
echo "Instalando ZeroTier..."
if [[ "$DISTRO" == "alpine" ]]; then
    wget https://download.zerotier.com/dist/Alpine/zerotier-one_latest_amd64.apk -O /tmp/zerotier.apk
    apk add --allow-untrusted /tmp/zerotier.apk
    rc-update add zerotier-one boot
    service zerotier-one start
else
    echo "Para outras distros, instale ZeroTier manualmente."
fi

# ===========================
# Mensagem final
# ===========================
echo "=========================================="
echo "VPS totalmente configurada!"
if [[ "$CREATE_USER" =~ ^[Ss]$ ]]; then
    echo "Usuário criado: $NEWUSER (sudo)"
fi
echo "Linguagens: Python, Node.js, Java, C/C++, Rust, PHP, Go"
echo "Servidores: Nginx, Apache"
echo "Bancos de dados: MariaDB, Redis"
echo "Docker instalado"
echo "VPNs: Hamachi (Alpine) e ZeroTier (Alpine)"
echo "Ferramentas básicas instaladas (Vim incluso)"
echo "=========================================="
