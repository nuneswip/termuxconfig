#!/usr/bin/env bash

clear

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
INVERSE="\033[7m"

echo -e "[${GREEN}+${RESET}] ${BOLD}Nuneswip Termux Preset${RESET}"
sleep 1

echo -e "[${CYAN}#${RESET}] Updating packages..."
pkg update -y
pkg upgrade -y

echo -e "[${CYAN}#${RESET}] Installing dependencies..."
pkg install -y \
git \
tree \
htop \
curl \
wget \
zsh \
starship \
nodejs \
npm \
python \
lua51 \
rust \
golang \
clang \
make \
cmake \
neovim \
ripgrep \
fd \
bat \
eza \
fzf \
unzip \
zip \
tar \
proot \
openssl \
pkg-config \
libffi \
termux-api

echo -e "[${GREEN}+${RESET}] Dependencies installed"

echo -e "[${CYAN}#${RESET}] Setting ZSH as default..."
chsh -s zsh

echo -e "[${CYAN}#${RESET}] Installing ZSH plugins..."

mkdir -p ~/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

echo -e "[${GREEN}+${RESET}] Plugins installed"

mkdir -p ~/.config/nuneswip

cat > ~/.config/nuneswip/motd.zsh << 'EOF'
nuneswip_motd() {
clear

FG1="\033[38;5;245m"
FG2="\033[38;5;240m"
RESET="\033[0m"

WIDTH=$(tput cols 2>/dev/null || echo 80)
SEP=$(printf '─%.0s' $(seq 1 $WIDTH))

USER_NAME=$(whoami)
DATE=$(date +"%d/%m %H:%M")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //')
DEVICE=$(getprop ro.product.model 2>/dev/null)
ANDROID=$(getprop ro.build.version.release 2>/dev/null)

IP=$(ip addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
MEM=$(free -m 2>/dev/null | awk '/Mem:/ {print $3"MB/"$2"MB"}')

echo "${FG2} Termux ${FG1}• ${USER_NAME} ${FG2}• ${DATE}${RESET}"
echo "${FG2}${SEP}${RESET}"

echo "${FG1}  Device  ${RESET} ${DEVICE:-unknown}"
echo "${FG1}  Android ${RESET} ${ANDROID:-?}"
echo "${FG1}  Network ${RESET} ${IP:-no connection}"
echo "${FG1}  Memory  ${RESET} ${MEM:-n/a}"
echo "${FG1}  Uptime  ${RESET} ${UPTIME:-unknown}"

echo "${FG2}${SEP}${RESET}"

echo ""
}
EOF

cat > ~/.zshrc << 'EOF'

eval "$(starship init zsh)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.config/nuneswip/motd.zsh
nuneswip_motd

alias ls="eza --icons"
alias ll="eza -la --icons"
alias cat="bat"
alias tree="tree -I 'node_modules'"
alias gclean="git add -A && git diff --cached --quiet || git commit -m \"cleanup: apply gitignore\" && git push origin main"
alias gb="git add -A && git diff --cached --quiet || git commit -m \"chore: sync\" && git push origin main"
alias gbk="git add -A && git diff --cached --quiet || git commit -m \"chore: backup snapshot\" && git push --force-with-lease backup backup-full"
alias b="./build.sh"

EOF

echo -e "[${CYAN}#${RESET}] Downloading Starship config..."

mkdir -p ~/.config

if command -v curl >/dev/null 2>&1; then
    curl -L https://raw.githubusercontent.com/nuneswip/termuxconfig/refs/heads/main/config.toml -o ~/.config/starship.toml
else
    wget -O ~/.config/starship.toml https://raw.githubusercontent.com/nuneswip/termuxconfig/refs/heads/main/config.toml
fi

echo -e "[${CYAN}#${RESET}] Installing Cargo tools..."

cargo install darklua --root $PREFIX

echo -e "[${CYAN}#${RESET}] Installing JetBrainsMono Nerd Font..."

mkdir -p ~/.termux
TMP_FONT_DIR="$(mktemp -d)"

curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o "$TMP_FONT_DIR/font.zip"

unzip "$TMP_FONT_DIR/font.zip" -d "$TMP_FONT_DIR"

REGULAR_FONT=$(find "$TMP_FONT_DIR" -name "*JetBrainsMono*Nerd*Regular.ttf" | head -n 1)

if [ -f "$REGULAR_FONT" ]; then
    mv "$REGULAR_FONT" ~/.termux/font.ttf
fi

rm -rf "$TMP_FONT_DIR"

termux-reload-settings

echo ""
echo -e "[${GREEN}+${RESET}] ${BOLD}Setup completed${RESET}"
echo -e "[${CYAN}#${RESET}] Restart Termux or run:"
echo ""
echo -e "${YELLOW}exec zsh${RESET}"
echo ""
