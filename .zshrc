# --- 0. Oh My Zsh 初期化 ---
export ZSH="$HOME/.oh-my-zsh"

# テーマ設定 (robbyrussell はフォント設定不要で Git 状態が見える名作です)
ZSH_THEME="robbyrussell"

# プラグインの有効化
# ※ zsh-syntax-highlighting は「最後に読み込む」のが zsh の鉄則なので最後に配置
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Oh My Zsh の読み込み (ここで compinit も内部で実行されます)
source $ZSH/oh-my-zsh.sh

# --- 1. エイリアス ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- 2. 環境に応じた設定の分岐 ---
case "$(uname)" in
  "Darwin") 
    # Mac 固有の設定
    [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
    ;;
  "Linux")
    # Dev Container (Linux) 固有の設定
    # コンテナ内だと一目でわかるように、プロンプトに少し手を加えるなどの遊びも可能
    ;;
esac

# --- 3. 共通の便利な設定 ---
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Ollama
export OLLAMA_HOST=0.0.0.0:11434

# パス追加 (自作スクリプト用)
export PATH="$HOME/.local/bin:$PATH"

# --- 4. 注意点 ---
# ※ 手動の 'compinit' は不要です。Oh My Zsh が内部で最適なタイミングで実行してくれます。
# 自分で書くと起動がコンマ数秒遅くなる原因になります。
