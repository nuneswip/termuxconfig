#!/usr/bin/env bash

clear

# Colors
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
pkg update -y >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1

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
 >/dev/null 2>&1

echo -e "[${GREEN}+${RESET}] Dependencies installed"

# Set ZSH
echo -e "[${CYAN}#${RESET}] Setting ZSH as default..."
chsh -s zsh >/dev/null 2>&1

# Plugins
echo -e "[${CYAN}#${RESET}] Installing ZSH plugins..."

mkdir -p ~/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions >/dev/null 2>&1
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting >/dev/null 2>&1

echo -e "[${GREEN}+${RESET}] Plugins installed"

# ZSHRC
echo -e "[${CYAN}#${RESET}] Configuring .zshrc..."

cat > ~/.zshrc << 'EOF'

# Starship
eval "$(starship init zsh)"

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases
alias ls="eza --icons"
alias ll="eza -la --icons"
alias cat="bat"
alias="tree -I "node_modules"
alias gclean="git add -A && git diff --cached --quiet || git commit -m \"cleanup: apply gitignore\" && git push origin main"
alias gb="git add -A && git diff --cached --quiet || git commit -m \"chore: sync\" && git push origin main"
alias gbk="git add -A && git diff --cached --quiet || git commit -m \"chore: backup snapshot\" && git push --force-with-lease backup backup-full"
alias b="./build.sh"

EOF

echo -e "[${GREEN}+${RESET}] .zshrc configured"

# Starship Config
echo -e "[${CYAN}#${RESET}] Configuring Starship..."

mkdir -p ~/.config

cat > ~/.config/starship.toml << 'EOF'
$schema = "https://starship.rs/config-schema.json"

palette = "monochrome"

format = "[$directory$git_branch$git_status] $character"
add_newline = false

[directory]
truncation_symbol = " "
truncation_length = 2
truncate_to_repo = true
style = "fg:frost"
format = "[$path]($style)"

[git_branch]
symbol = ""
style = "fg:spark"
format = " | [[$symbol $branch](fg:spark)]($style)"

[git_status]
format = "$all_status$ahead_behind"

[character]
success_symbol = "[$](fg:lime)"
error_symbol = "[$](fg:ember)"

[palettes.monochrome]
text = "#ffffff"
frost = "#868686"
spark = "#aeaeae"
lime = "#a4a4a4"
ember = "#cccccc"
EOF

echo -e "[${GREEN}+${RESET}] Starship configured"

# Cargo tools
echo -e "[${CYAN}#${RESET}] Installing Cargo tools..."

cargo install darklua >/dev/null 2>&1

echo -e "[${GREEN}+${RESET}] Cargo tools installed"

# Nerd Font
echo -e "[${CYAN}#${RESET}] Installing JetBrainsMono Nerd Font..."

mkdir -p ~/.termux
TMP_FONT_DIR="$(mktemp -d)"

curl -fsSL \
https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
-o "$TMP_FONT_DIR/font.zip" >/dev/null 2>&1

unzip -q "$TMP_FONT_DIR/font.zip" -d "$TMP_FONT_DIR" >/dev/null 2>&1

REGULAR_FONT=$(find "$TMP_FONT_DIR" -name "*JetBrainsMono*Nerd*Regular.ttf" | head -n 1)

if [ -f "$REGULAR_FONT" ]; then
    mv "$REGULAR_FONT" ~/.termux/font.ttf
    echo -e "[${GREEN}+${RESET}] JetBrainsMono Nerd Font installed"
else
    echo -e "[${RED}x${RESET}] Failed to install font"
fi

rm -rf "$TMP_FONT_DIR"

termux-reload-settings >/dev/null 2>&1

echo -e ""
echo -e "[${GREEN}+${RESET}] ${BOLD}Setup completed${RESET}"
echo -e "[${CYAN}#${RESET}] Restart Termux or run:"
echo -e ""
echo -e "${YELLOW}exec zsh${RESET}"
echo -e ""
