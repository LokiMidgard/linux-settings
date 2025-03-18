# download the other files to user home

DATA_STORE="https://raw.githubusercontent.com/LokiMidgard/linux-settings/refs/heads/main"

curl  -fsSL -o ~/update.sh $DATA_STORE/update.sh
curl  -fsSL -o ~/.zshrc $DATA_STORE/.zshrc
curl  -fsSL -o ~/.p10k.zsh $DATA_STORE/.p10k.zsh
curl  -fsSL -o ~/.zsh_custom $DATA_STORE/.zsh_custom
curl  -fsSL -o ~/update-certificates.sh $DATA_STORE/update-certificates.sh

# update the certificates
chmod +x ~/update-certificates.sh
sudo ~/update-certificates.sh

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
