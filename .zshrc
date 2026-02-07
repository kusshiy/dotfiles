# --- 1. プロンプト設定 (Macのデザインを再現) ---
# %m (ホスト名) はコンテナIDになるので便利です
# %w %T (日付と時刻) も引き継ぎました
PROMPT='%F{2}devcontainer@%m%f%F{15}:%f%F{21}%~%f %F{8}%w %T%f
$ '

# コマンド実行ごとの改行設定 (add_line関数)
function add_line {
  if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}
precmd_functions+=(add_line)

# --- 2. エイリアス (これは共通で便利なので引き継ぐ) ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# --- 3. 環境に応じた設定の分岐 ---
# ここが重要です。「MacならHomebrew」「Linuxなら何もしない」などを分けます
case "$(uname)" in
  "Darwin") 
    # Mac (Homebrew, Pyenv, CondaなどはMacでのみ有効にする)
    [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
    
    # Conda設定などは必要ならここに書く（コンテナ内では不要なことが多いので省略推奨）
    ;;
  "Linux")
    # Linux (Dev Container内)
    # ここにDev Container特有の設定があれば書く
    ;;
esac

# --- 4. 共通の便利な設定 ---
# nvmの設定 (Dev Containerによく入ってるのでチェックして読み込む)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Ollamaの設定 (引き継ぎ)
export OLLAMA_HOST=0.0.0.0:11434

# パスの追加
export PATH="$HOME/.local/bin:$PATH"

# --- 5. 補完機能の有効化 ---
autoload -Uz compinit
compinit