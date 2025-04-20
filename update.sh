# download the other files to user home

DATA_STORE="https://raw.githubusercontent.com/LokiMidgard/linux-settings/refs/heads/main"

# Zielverzeichnis für die Fonts
MESLO_FONT_DIR="$HOME/.local/share/fonts/Meslo"
MESLO_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.tar.xz"


# Zielverzeichnis für die Fonts
OD_FONT_DIR="$HOME/.local/share/fonts/OpenDyslexic"
OD_FONT_URL="https://github.com/antijingoist/opendyslexic/releases/download/v0.91.12/opendyslexic-0.910.12-rc2-2019.10.17.zip"

# helper functions
install_font() {
    local font_url="$1"
    local font_dir="$2"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local file_name="$tmp_dir/$(basename "$font_url")"

    if [ -d "$font_dir" ]; then
        echo "Font unter $font_dir ist bereits installiert."
        rm -rf "$tmp_dir"
        return
    fi

    echo "Font wird von $font_url heruntergeladen und installiert..."

    mkdir -p "$font_dir"

    # Download
    curl -L -o "$file_name" "$font_url"

    # Entpacken je nach Dateityp
    case "$file_name" in
        *.zip)
            unzip -j "$file_name" '*.otf' '*.ttf' -d "$font_dir"
            ;;
        *.tar|*.tar.gz|*.tar.xz)
            tar --wildcards -xf "$file_name" --directory="$font_dir" --no-anchored '*.otf' '*.ttf'
            ;;
        *)
            echo "Unbekanntes Archivformat: $file_name"
            rm -rf "$tmp_dir"
            return 1
            ;;
    esac

    # Font-Cache aktualisieren
    fc-cache -fv

    # Aufräumen
    rm -rf "$tmp_dir"

    echo "Font erfolgreich installiert unter $font_dir."
}


# SCRIPT STARTS HERE


curl -fsSL -o ~/update.sh $DATA_STORE/update.sh
chmod +x ~/update.sh

curl -fsSL -o ~/update-certificates.sh $DATA_STORE/update-certificates.sh

# update the certificates
chmod +x ~/update-certificates.sh
sudo ~/update-certificates.sh

if ! command -v git &>/dev/null; then
    echo "git could not be found, installing..."

    # install git
    sudo apt install git -y
fi

# set git config
git config --global user.name "Patrick Kranz"
git config --global user.email "patrick-kranz@live.de"

# check if zsh is installed, if not install it
if ! command -v zsh &>/dev/null; then
    echo "zsh could not be found, installing..."

    # install zsh
    sudo apt install zsh -y
    sudo chsh -s $(which zsh)

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install plugins
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

fi

if ! command -v docker &>/dev/null; then
    echo "docker could not be found, installing..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    echo "Docker installiert. Bitte einmal neu einloggen oder 'newgrp docker' ausführen, damit Gruppenänderung greift."
fi


# Sicherstellen dass unzip da ist
if ! command -v unzip &>/dev/null; then
    echo "unzip nicht gefunden, wird installiert..."
    sudo apt-get install -y unzip
fi
# Prüfen ob der Font bereits installiert ist
if [ -d "$OD_FONT_DIR" ]; then
    echo "OpenDyslexic Font ist bereits installiert."
else
    echo "OpenDyslexic Font wird heruntergeladen und installiert..."

    # temporäres Verzeichnis erstellen
    mkdir -p "$OD_TMP_DIR"
    mkdir -p "$OD_FONT_DIR"

    # Archiv herunterladen
    curl -L -o "$OD_ZIP" "$OD_FONT_URL"

    # Nur OTF-Dateien extrahieren
    unzip -j "$OD_ZIP" '*.otf' -d "$OD_FONT_DIR"

    # Font-Cache aktualisieren
    fc-cache -fv

    # temporäres Verzeichnis entfernen
    rm -rf "$OD_TMP_DIR"

    echo "OpenDyslexic Font erfolgreich installiert."
fi


# Prüfen ob der Font bereits installiert ist
if [ -d "$FONT_DIR" ]; then
    echo "Meslo Nerd Font ist bereits installiert."
else
    echo "Meslo Nerd Font wird heruntergeladen und installiert..."

    # temporäres Verzeichnis erstellen
    mkdir -p "$FONT_TMP_DIR"
    mkdir -p "$FONT_DIR"

    # Archiv herunterladen
    curl -L -o "$FONT_ARCHIVE" "$FONT_URL"

    # Archiv entpacken
    tar -xf "$FONT_ARCHIVE" -C "$FONT_DIR"

    # Font-Cache aktualisieren
    fc-cache -fv

    # temporäres Verzeichnis entfernen
    rm -rf "$FONT_TMP_DIR"

    echo "Meslo Nerd Font erfolgreich installiert."
fi

# install the fonts
install_font "$MESLO_FONT_URL" "$MESLO_FONT_DIR"
install_font "$OD_FONT_URL" "$OD_FONT_DIR"


curl -fsSL -o ~/.zshrc $DATA_STORE/.zshrc
curl -fsSL -o ~/.p10k.zsh $DATA_STORE/.p10k.zsh
curl -fsSL -o ~/.zsh_custom $DATA_STORE/.zsh_custom
