#!/bin/bash

# Instalar dependências para o asdf
echo "Instalando dependências..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    unzip \
    libssl-dev \
    zlib1g-dev \
    libreadline-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm-dev \
    libbz2-dev \
    liblzma-dev \
    tk-dev \
    libcurl4-openssl-dev \
    libjpeg8-dev \
    libpng-dev \
    libsqlite3-dev \
    libgmp-dev

# Instalar plugins do asdf
echo "Instalando plugins do asdf..."

# Java
asdf plugin add java
asdf plugin add maven
asdf plugin add nodejs
asdf plugin add ruby
asdf plugin add rust

# Instalar as versões específicas
echo "Instalando versões..."

# Liberica JavaFX 22.0.2+11
asdf install java liberica-22.0.2+11
asdf set -u java liberica-22.0.2+11

# OpenJDK 17.0.2
asdf install java openjdk-17.0.2
asdf set -u java openjdk-17.0.2

# OpenJDK 24
# Não há suporte oficial para OpenJDK 24 via asdf. Podemos usar a versão mais próxima disponível.
asdf install java openjdk-24
asdf set -u java openjdk-24

# Maven 3.9.9
asdf install maven 3.9.9
asdf set -u maven 3.9.9

# Node.js 23.0.0
asdf install nodejs 23.0.0
asdf set -u nodejs 23.0.0

# Ruby 3.4.2
asdf install ruby 3.4.2
asdf set -u ruby 3.4.2

# Rust 1.85.0
asdf install rust 1.85.0
asdf set -u rust 1.85.0

echo "Instalação concluída!"
