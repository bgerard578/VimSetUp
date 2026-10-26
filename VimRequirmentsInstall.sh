#!/usr/bin/env bash

# Vim + coc.nvim setup for Kali Linux, Debian, and Ubuntu.
# Place this script in the same directory as the GitHub file named "vimrc".

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG="$HOME/vim-setup-install.log"
VIMRC_SOURCE="$SCRIPT_DIR/vimrc"
COC_DIR="$HOME/.vim/pack/coc/start/coc.nvim"

mkdir -p "$HOME"
touch "$LOG"

log()  { echo "[INFO] $*" | tee -a "$LOG"; }
ok()   { echo "[ OK ] $*" | tee -a "$LOG"; }
warn() { echo "[WARN] $*" | tee -a "$LOG" >&2; }

has() { command -v "$1" >/dev/null 2>&1; }

log "Starting Vim setup..."

# 1. Copy vimrc to ~/.vimrc, preserving a backup if needed.
if [[ -f "$VIMRC_SOURCE" ]]; then
    if [[ -f "$HOME/.vimrc" ]] && cmp -s "$VIMRC_SOURCE" "$HOME/.vimrc"; then
        ok ".vimrc already matches; skipping copy."
    else
        if [[ -f "$HOME/.vimrc" ]]; then
            BACKUP="$HOME/.vimrc.backup.$(date +%Y%m%d-%H%M%S)"
            if cp -p "$HOME/.vimrc" "$BACKUP"; then
                log "Backed up existing .vimrc to $BACKUP"
            else
                warn "Could not back up existing .vimrc; not replacing it."
                VIMRC_SOURCE=""
            fi
        fi

        if [[ -n "$VIMRC_SOURCE" ]] && cp "$VIMRC_SOURCE" "$HOME/.vimrc"; then
            ok "Installed ~/.vimrc"
        elif [[ -n "$VIMRC_SOURCE" ]]; then
            warn "Could not copy vimrc."
        fi
    fi
else
    warn "File 'vimrc' not found beside this script."
    warn "Download both files into the same directory."
fi

# 2. Install missing system packages.
if has apt-get; then
    PACKAGES=()

    for pkg in vim git curl build-essential clang clangd \
               shellcheck shfmt nodejs npm python3; do
        case "$pkg" in
            build-essential)
                dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null |
                    grep -q 'install ok installed' || PACKAGES+=("$pkg")
                ;;
            *)
                has "$pkg" || PACKAGES+=("$pkg")
                ;;
        esac
    done

    if ((${#PACKAGES[@]})); then
        log "Installing missing packages: ${PACKAGES[*]}"

        if has sudo; then
            sudo apt-get update ||
                warn "Package list update failed."
            sudo apt-get install -y "${PACKAGES[@]}" ||
                warn "Some system packages failed to install."
        elif [[ "$EUID" -eq 0 ]]; then
            apt-get update || warn "Package list update failed."
            apt-get install -y "${PACKAGES[@]}" ||
                warn "Some system packages failed to install."
        else
            warn "Cannot install packages: sudo is unavailable."
        fi
    else
        ok "System packages already installed."
    fi
else
    warn "This script requires apt-get (Kali/Debian/Ubuntu)."
fi

# 3. Check Node.js compatibility.
if has node; then
    NODE_VERSION="$(node -p 'process.versions.node' 2>/dev/null || true)"
    ok "Node.js version: $NODE_VERSION"

    if ! node -e '
      const [a,b,c] = process.versions.node.split(".").map(Number);
      process.exit(a > 22 || (a === 22 && (b > 15 || (b === 15 && c >= 0))) ? 0 : 1)
    ' 2>/dev/null; then
        warn "Current coc.nvim needs Node.js 22.15.0 or newer."
        warn "Upgrade Node.js if coc.nvim fails to start."
    fi
else
    warn "Node.js not found; coc.nvim needs Node.js 22.15.0 or newer."
fi

# 4. Install coc.nvim if missing.
if [[ -d "$COC_DIR/.git" ]]; then
    ok "coc.nvim already installed."
elif [[ -e "$COC_DIR" ]]; then
    warn "$COC_DIR exists but is not a Git checkout; leaving it unchanged."
elif has git; then
    mkdir -p "$(dirname "$COC_DIR")"
    if git clone --depth=1 --branch release \
        https://github.com/neoclide/coc.nvim.git "$COC_DIR"; then
        ok "Installed coc.nvim."
    else
        warn "Could not install coc.nvim."
    fi
else
    warn "Git is missing; cannot install coc.nvim."
fi

# 5. Add .NET global tools to PATH once.
PATH_LINE='export PATH="$PATH:$HOME/.dotnet/tools"'

if ! grep -Fqx "$PATH_LINE" "$HOME/.bashrc" 2>/dev/null; then
    printf '\n# .NET global tools\n%s\n' "$PATH_LINE" >> "$HOME/.bashrc"
    ok "Added .NET tools to PATH in ~/.bashrc."
else
    ok ".NET tools PATH entry already exists."
fi

export PATH="$PATH:$HOME/.dotnet/tools"

# 6. Install the .NET 6-compatible csharp-ls version.
if has dotnet; then
    if dotnet tool list --global 2>/dev/null |
        awk '$1=="csharp-ls" && $2=="0.5.4" {found=1}
             END {exit !found}'; then
        ok "csharp-ls 0.5.4 already installed."
    else
        log "Installing csharp-ls 0.5.4..."
        dotnet tool install --global csharp-ls --version 0.5.4 ||
            warn "csharp-ls installation failed; check .NET and NuGet."
    fi
else
    warn ".NET SDK not found; skipping csharp-ls."
fi

# 7. Install/check coc.nvim language extensions.
if [[ -d "$COC_DIR" ]] && has vim && has node; then
    log "Installing/checking coc.nvim extensions..."

    vim -Nu "$HOME/.vimrc" -n -es \
        -c 'CocInstall -sync coc-pyright coc-sh coc-clangd' \
        -c 'qa!' ||
        warn "Automatic extension installation failed. Install them inside Vim."
else
    warn "Skipping extension installation: Vim, Node.js, or coc.nvim missing."
fi

cat <<EOF

Setup pass finished.

Log file:
  $LOG

If extensions did not install, open Vim and run:
  :CocInstall coc-pyright coc-sh coc-clangd

For C# autocomplete, complete the CocConfig step in the README.
The script does not overwrite existing CocConfig settings.
EOF

ok "Finished."
