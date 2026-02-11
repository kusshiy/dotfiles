#!/bin/sh

echo "Starting Dotfiles installation..."

# --- 0. 環境チェック ---
DOTFILES_DIR="${HOME}/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

# --- 1. Zshのインストール (OS自動判定) --- 
if [ -f /sbin/apk ]; then
    echo "Detected Alpine Linux. Installing Zsh & tools..."
    sudo apk update && sudo apk add zsh git curl zsh-vcs
elif [ -f /usr/bin/apt-get ]; then
    echo "Detected Debian/Ubuntu. Installing Zsh..."
    sudo apt-get update && sudo apt-get install -y zsh git curl
fi

# --- 1.5 Oh My Zsh & Plugins の導入 ---
echo "Installing Oh My Zsh and plugins..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
# 各種プラグインのクローン
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# --- 2. 設定ファイルのシンボリックリンク作成 ---
echo "Linking configuration files..."
# Oh My Zsh が作ったデフォルトの .zshrc を自分の設定で上書きする
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

# --- 3. シェルの切り替え設定 (代替手段) ---
# chsh が制限されている環境でも、対話実行時のみ zsh に切り替える
current_shell=$(echo $SHELL)
if [ "$current_shell" != "/bin/zsh" ] && [ "$current_shell" != "/usr/bin/zsh" ]; then
    echo "Configuring auto-start zsh..."
    for config_file in ~/.bashrc ~/.profile; do
        if [ -f "$config_file" ]; then
            if ! grep -q "exec zsh" "$config_file"; then
                echo "[ -t 1 ] && exec zsh" >> "$config_file"
            fi
        fi
    done
fi

# --- 4. 個人的なツールのインストール ---
echo "Checking Global NPM Packages..."
if command -v npm >/dev/null 2>&1; then
    # インストール済みかチェックして、未導入のものだけ入れる（リビルド高速化）
    for pkg in @anthropic-ai/claude-code @google/gemini-cli; do
        if ! npm list -g "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            sudo npm install -g "$pkg"
        fi
    done
else
    echo "npm not found. Skipping package installation."
fi

echo "Dotfiles installation complete!"
