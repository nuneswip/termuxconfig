#!/usr/bin/env node

const { execSync } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

const COLORS = {
    RED: "\x1b[31m",
    GREEN: "\x1b[32m",
    YELLOW: "\x1b[33m",
    CYAN: "\x1b[36m",
    BOLD: "\x1b[1m",
    RESET: "\x1b[0m"
};

const HOME = os.homedir();

const TMP_DIR = fs.mkdtempSync(path.join(os.tmpdir(), "nuneswip-setup-"));

function run(command, options = {}) {
    try {
        execSync(command, {
            stdio: "inherit",
            shell: true,
            ...options
        });
    } catch (err) {
        console.error(
            `${COLORS.RED}[!] Command failed:${COLORS.RESET} ${command}`
        );
    }
}

function log(type, message) {
    const symbol =
        type === "success"
            ? `${COLORS.GREEN}+${COLORS.RESET}`
            : `${COLORS.CYAN}#${COLORS.RESET}`;

    console.log(`[${symbol}] ${message}`);
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function cleanup() {
    try {
        fs.rmSync(TMP_DIR, {
            recursive: true,
            force: true
        });
    } catch (_) {}
}

process.on("exit", cleanup);
process.on("SIGINT", () => {
    cleanup();
    process.exit(0);
});

(async () => {
    console.clear();

    console.log(
        `[${COLORS.GREEN}+${COLORS.RESET}] ${COLORS.BOLD}Nuneswip Termux Preset${COLORS.RESET}`
    );

    await sleep(1000);

    log("info", "Updating packages...");
    run("pkg update -y");
    run("pkg upgrade -y");

    log("info", "Installing dependencies...");

    const packages = [
        "git",
        "tree",
        "htop",
        "curl",
        "wget",
        "zsh",
        "starship",
        "nodejs",
        "npm",
        "python",
        "lua51",
        "rust",
        "golang",
        "clang",
        "make",
        "cmake",
        "neovim",
        "ripgrep",
        "fd",
        "bat",
        "eza",
        "fzf",
        "unzip",
        "zip",
        "tar",
        "proot",
        "openssl",
        "pkg-config",
        "libffi",
        "termux-api",
        "openjdk-25",
        "openjdk-21",
        "openjdk-17"
    ];

    run(`pkg install -y ${packages.join(" ")}`);

    log("info", "Installing global NPM packages...");

    run("npm install -g acode-lsp");
    run("npm install -g @thraize/acode-cli");

    log("success", "Global NPM packages installed");

    log("success", "Dependencies installed");

    log("info", "Setting ZSH as default...");
    run("chsh -s zsh");

    log("info", "Removing default MOTD...");
    run("rm -f $PREFIX/etc/motd");

    log("info", "Installing ZSH plugins...");

    fs.mkdirSync(path.join(HOME, ".zsh"), {
        recursive: true
    });

    run(
        "git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions"
    );

    run(
        "git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting"
    );

    log("success", "Plugins installed");

    fs.mkdirSync(path.join(HOME, ".config/nuneswip"), {
        recursive: true
    });

    const motdContent = `
nuneswip_motd() {
clear

WIDTH=$(tput cols 2>/dev/null || echo 80)
SEP=$(printf '─%.0s' $(seq 1 $WIDTH))

USER_NAME=$(whoami)
DATE=$(date +"%d/%m %H:%M")
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //')
DEVICE=$(getprop ro.product.model 2>/dev/null)
ANDROID=$(getprop ro.build.version.release 2>/dev/null)

IP=$(ip addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
MEM=$(free -m 2>/dev/null | awk '/Mem:/ {print $3"MB/"$2"MB"}')

echo " Termux • \${USER_NAME} • \${DATE}"
echo "\${SEP}"

echo "  Device  \${DEVICE:-unknown}"
echo "  Android \${ANDROID:-?}"
echo "  Network \${IP:-no connection}"
echo "  Memory  \${MEM:-n/a}"
echo "  Uptime  \${UPTIME:-unknown}"

echo "\${SEP}"

echo ""
}
`;

    fs.writeFileSync(path.join(HOME, ".config/nuneswip/motd.zsh"), motdContent);

    const zshrcContent = `
eval "$(starship init zsh)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.config/nuneswip/motd.zsh
nuneswip_motd

alias ls="eza --icons"
alias ll="eza -la --icons"
alias cat="bat"
alias tree="tree -I 'node_modules'"
alias gclean="git add -A && git diff --cached --quiet || git commit -m \\"cleanup: apply gitignore\\" && git push origin main"
alias gb='git add -A && ( git diff --cached --quiet && echo "Nothing to commit" || git commit -m "chore: sync" ) && git push origin main'
alias gbk="git add -A && git diff --cached --quiet || git commit -m \\"chore: backup snapshot\\" && git push --force-with-lease backup backup-full"
alias b="./build.sh"
`;

    fs.writeFileSync(path.join(HOME, ".zshrc"), zshrcContent);

    log("info", "Downloading Starship config...");

    fs.mkdirSync(path.join(HOME, ".config"), {
        recursive: true
    });

    run(`
if command -v curl >/dev/null 2>&1; then
    curl -L https://raw.githubusercontent.com/nuneswip/termuxconfig/refs/heads/main/config.toml -o ~/.config/starship.toml
else
    wget -O ~/.config/starship.toml https://raw.githubusercontent.com/nuneswip/termuxconfig/refs/heads/main/config.toml
fi
`);

    log("info", "Installing Cargo tools...");

    run("cargo install darklua --root $PREFIX");

    log("info", "Installing JetBrainsMono Nerd Font...");

    fs.mkdirSync(path.join(HOME, ".termux"), {
        recursive: true
    });

    const fontZip = path.join(TMP_DIR, "JetBrainsMono.zip");

    run(`
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -o "${fontZip}"
`);

    run(`
unzip "${fontZip}" -d "${TMP_DIR}/fonts"
`);

    const regularFont = execSync(
        `find "${TMP_DIR}/fonts" -name "*JetBrainsMono*Nerd*Regular.ttf" | head -n 1`,
        {
            encoding: "utf8",
            shell: true
        }
    ).trim();

    if (regularFont && fs.existsSync(regularFont)) {
        fs.copyFileSync(regularFont, path.join(HOME, ".termux/font.ttf"));
    }

    run("termux-reload-settings");

    log("info", "Downloading JDTLS...");

    const jdtlsArchive = path.join(TMP_DIR, "jdt-language-server.tar.gz");

    run(`
curl -L "https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.58.0/jdt-language-server-1.58.0-202604151538.tar.gz" -o "${jdtlsArchive}"
`);

    fs.mkdirSync(path.join(HOME, "jdtls"), {
        recursive: true
    });

    log("info", "Extracting JDTLS...");

    run(`
tar -xzf "${jdtlsArchive}" -C "${HOME}/jdtls"
`);

    console.log("");
    console.log(
        `[${COLORS.GREEN}+${COLORS.RESET}] ${COLORS.BOLD}Setup completed${COLORS.RESET}`
    );

    console.log(`[${COLORS.CYAN}#${COLORS.RESET}] Restart Termux or run:`);

    console.log("");
    console.log(`${COLORS.YELLOW}exec zsh${COLORS.RESET}`);
    console.log("");
})();
