#!/bin/sh

echo "Starting Dotfiles installation..."

# --- 0. 環境チェック ---
# dotfilesの場所を特定 (VS Codeは通常 ~/dotfiles にcloneしますが念のため)
DOTFILES_DIR="${HOME}/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

# --- 1. Zshのインストール (OS自動判定) ---
if [ -f /sbin/apk ]; then
    # Alpine Linux
    echo "Detected Alpine Linux. Installing Zsh & tools..."
    sudo apk update && sudo apk add zsh git curl zsh-vcs zsh-syntax-highlighting zsh-autosuggestions
elif [ -f /usr/bin/apt-get ]; then
    # Debian / Ubuntu
    echo "Detected Debian/Ubuntu. Installing Zsh..."
    sudo apt-get update && sudo apt-get install -y zsh git curl
fi

# --- 2. 設定ファイルのシンボリックリンク作成 ---
echo "Linking configuration files..."
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

# もし .gitconfig なども追加したらここ行を増やすだけ
# ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig

# --- 3. シェルの切り替え設定 ---
# 現在のユーザーのデフォルトシェルが zsh でない場合、
# コンテナ起動時に zsh を実行するように .bashrc 等に追記するハック
# (chsh が使えない環境への対策)
current_shell=$(echo $SHELL)
if [ "$current_shell" != "/bin/zsh" ] && [ "$current_shell" != "/usr/bin/zsh" ]; then
    echo "Configuring auto-start zsh..."
    # .profile や .bashrc があれば、末尾に 'exec zsh' を追加して無理やり切り替える
    for config_file in ~/.bashrc ~/.profile; do
        if [ -f "$config_file" ]; then
            if ! grep -q "exec zsh" "$config_file"; then
                echo "[ -t 1 ] && exec zsh" >> "$config_file"
                echo "Added zsh auto-start to $config_file"
            fi
        fi
    done
fi

# --- 4. 個人的なツールのインストール ---
echo "Installing Global NPM Packages..."
# npm があるかチェックしてから実行
if command -v npm >/dev/null 2>&1; then
    sudo npm install -g @anthropic-ai/claude-code @google/gemini-cli @openai/codex
else
    echo "npm not found. Skipping package installation."
fi

echo "Dotfiles installation complete!"