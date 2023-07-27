# Initialize the completion engine
ZGEN_AUTOLOAD_COMPINIT=1

# Automatically regenerate zgen configuration when ~/.rad-plugins changes
ZGEN_RESET_ON_CHANGE=($HOME/.rad-plugins $HOME/.zshrc)

ZGEN_PREZTO_LOAD_DEFAULT=${ZGEN_PREZTO_LOAD_DEFAULT:-1}

if [[ -z "${ZGEN_PREZTO_LOAD}" ]]; then
  ZGEN_PREZTO_LOAD=("'history-substring-search'" "'git'" "'fasd'")
fi

_ZGEN_OHMYZSH_LOAD_DEFAULT=${_ZGEN_OHMYZSH_LOAD_DEFAULT:-}
if [[ -z "${_ZGEN_OHMYZSH_DEFAULT_LOAD_LIST}" ]]; then
  _ZGEN_OHMYZSH_DEFAUL_LOAD_LIST=(lib/git.zsh lib/prompt_info_functions.zsh lib/theme-and-appearance.zsh)
fi

# Plugins can register an init hook that will be called after all plugins are loaded
# This allows us to avoid module load order dependencies by delaying initialization until dependencies have all been loaded
declare -a rad_plugin_init_hooks

zstyle ':prezto:module:terminal' auto-title 'yes'
zstyle ':prezto:module:terminal:window-title' format '%n@%m'
zstyle ':prezto:module:terminal:tab-title' format '%s'

# Remove alias 'rm' -> 'rm -i' if it exists
alias rm &>/dev/null && unalias rm

# Use bash-style word delimiters
autoload -U select-word-style
select-word-style bash

source "${HOME}/.zgen/zgen.zsh"
# if the init scipt doesn't exist
if ! zgen saved; then

  # Loads prezto base and default plugins:
  # environment terminal editor history directory spectrum utility completion prompt
  zgen prezto

  # Initializes some functionality baked into rad-shell
  zgen load brandon-fryslie/rad-shell init-plugin

  # Initialize oh-my-zsh libraries required to use oh-my-zsh themes
  if [[ ${_ZGEN_OHMYZSH_LOAD_DEFAULT} != 0 ]]; then
    for script in ${_ZGEN_OHMYZSH_DEFAUL_LOAD_LIST[@]}; do
      zgen load ohmyzsh/ohmyzsh ${script}
    done
  fi

  # Here is where we load plugins from $HOME/.rad-plugins
  while read -r line; do
    if [[ ! $line =~ '^#' ]] && [[ ! $line == '' ]]; then
      echo "Loading plugin: $line"
      eval "zgen load $line"
    fi
  done < $HOME/.rad-plugins

  zgen save
fi

for init_hook in "${rad_plugin_init_hooks[@]}"; do
  # Pass the script path to the init hook
  ${init_hook%%:*} ${init_hook##*:}
done
