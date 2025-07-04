if [[ -f ~/.config/posix-sh/config.sh ]]
then emulate sh -c 'source ~/.config/posix-sh/config.sh'
fi

PROMPT='%F{blue}%~%f %#'
REPORTTIME=10
WORDCHARS=${WORDCHARS/\/}
WORDCHARS=${WORDCHARS/=}

bindkey -M emacs '\e[5~' history-beginning-search-backward # PgUp
bindkey -M emacs '\e[6~' history-beginning-search-forward # PgDn
bindkey -M emacs '\e[3~' delete-char # Delete
bindkey -M emacs '\e[H' beginning-of-line # Home
bindkey -M emacs '\e[F' end-of-line # End
bindkey -M isearch '\e[5~' history-incremental-search-backward # PgUp
bindkey -M isearch '\e[6~' history-incremental-search-forward # PgDn

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' menu select

# history-related options
setopt extended_history inc_append_history_time
setopt hist_ignore_dups hist_ignore_space hist_no_store hist_reduce_blanks

# other options
setopt correct interactive_comments list_packed magic_equal_subst numeric_glob_sort print_exit_value

autoload -Uz add-zsh-hook
2>/dev/null source ~/.config/zsh/report-completion.zsh

function {
	local magenta_bold=`tput setaf 5; tput bold` cyan=`tput setaf 6` reset=`tput sgr0`
	local lines=(
		"$magenta_bold== time report ==$reset"
		' command: %J'
		" user: $cyan%U$reset system: $cyan%S$reset total: $cyan%*E$reset CPU: $cyan%P$reset"
	)
	TIMEFMT=${(F)lines}
}

function set-terminal-title {
	printf '\e]0;%s\a' "$*"
}

if [[ -n TMUX ]] && [[ -z _TMUX_PANE_TITLE_INITIALIZED ]]
then
	set-terminal-title

	# Only reset it once, at the top-level shell.
	export _TMUX_PANE_TITLE_INITIALIZED=true
fi

# When something happens to the connection, tmux/screen doesn’t have a chance to
# clean up the terminal title. OpenSSH regards such a case as “an error
# occurred”, and exits with 255.
# https://manpages.debian.org/bullseye/openssh-client/ssh.1.en.html#EXIT_STATUS
function FranklinYu::recover-terminal-title {
	local cmd_status=$status last_command_str=$history[$((HISTCMD-1))]
	local last_exec=${${(Az)last_command_str}[1]}
	local last_exec_is_ssh="${FranklinYu_ssh_commands[(Ie)$last_exec]}"
	if (( last_exec_is_ssh )) && (( cmd_status == 255 ))
	then set-terminal-title
	fi
}
FranklinYu_ssh_commands=(ssh)
add-zsh-hook precmd FranklinYu::recover-terminal-title

function {
	local file='Contents/Resources/iterm2_shell_integration.zsh'
	2>/dev/null source /Applications/MacPorts/iTerm2.app/$file ||
		2>/dev/null source /Applications/iTerm.app/$file
}
# https://iterm2.com/documentation-scripting-fundamentals.html#setting-user-defined-variables
function iterm2_print_user_vars {
	iterm2_set_user_var ruby_version ${RUBY_VERSION:-system}
	if command -v nvm >/dev/null
	then iterm2_set_user_var node_version `nvm version`
	fi
	it2git 2>/dev/null
}

function source-from-share {
	2>/dev/null source "/usr/share/$1" ||
		2>/dev/null source "/usr/local/share/$1" ||
		2>/dev/null source "/opt/local/share/$1"
}

if source-from-share chruby/chruby.sh && source-from-share chruby/auto.sh
then
	add-zsh-hook -d preexec chruby_auto
	add-zsh-hook precmd chruby_auto
fi

source-from-share nvm/nvm.sh

function {
	local preview_command
	if whence -p bat >/dev/null
	then preview_command='bat --style=numbers --color=always --line-range :500 {}'
	elif whence -p highlight >/dev/null
	then
		if (( `tput colors` == 256 ))
		then preview_command='highlight --out-format=xterm256 --line-numbers --line-range=1-500 {}'
		else preview_command='highlight --out-format=ansi --line-range=0-500 {}'
		fi
	else preview_command='cat {}'
	fi
	preview_command="--preview '$preview_command'"

	if source-from-share skim/shell/key-bindings.zsh || # Homebrew, MacPorts, and Fedora
		2>/dev/null source /usr/share/skim/key-bindings.zsh # Arch Linux
	then
		bindkey '^\' skim-cd-widget
		SKIM_CTRL_T_OPTS=$preview_command
	elif source-from-share fzf/shell/key-bindings.zsh ||
		2>/dev/null source /usr/share/fzf/key-bindings.zsh ||
		2>/dev/null source /usr/share/doc/fzf/examples/key-bindings.zsh # Debian
	then
		bindkey '^\' fzf-cd-widget
		FZF_CTRL_T_OPTS=$preview_command
	fi
}

unfunction source-from-share

source ~/.local/share/zinit/zinit.git/zinit.zsh

# https://github.com/zdharma-continuum/fast-syntax-highlighting/releases/tag/v1.55
zinit ice ver"5351bd907ea39d9000b7bd60b5bb5b0b1d5c8046"
zinit light zdharma-continuum/fast-syntax-highlighting

# https://github.com/zsh-users/zsh-autosuggestions/releases/tag/v0.7.1
zinit ice ver"e52ee8ca55bcc56a17c828767a3f98f22a68d4eb"
zinit light zsh-users/zsh-autosuggestions

#---------------------------------------------------------------
# aliases

# https://superuser.com/questions/1586794/vscode-cd-to-workspace-folder
if [[ -v VSCODE_WORKSPACE && $VSCODE_WORKSPACE != '${workspaceFolder}' ]]
then alias cd="HOME=${VSCODE_WORKSPACE:q} cd"
fi

# https://unix.stackexchange.com/questions/108699/documentation-on-less-termcap-variables
function {
	declare -A mappings=(
		[md]='%F{cyan}' # start of bold
		[me]='%f' # end of bold
		[us]='%F{green}%U' # start of underline
		[ue]='%f%u' # end of underline
		[so]='%F{black}%K{yellow}' # start of standout
		[se]='%f%k' # end of standout
	)

	local env_vars=() termcap terminfo
	for termcap terminfo in ${(@kv)mappings}
	do env_vars+=$(printf 'LESS_TERMCAP_%s=%s' $termcap ${(%)terminfo})
	done
	env_vars+='LESS=--LONG-PROMPT'
	alias man="$env_vars man"
}

# Needs to be after sourcing chruby.
function {
	local ll_prefix=''
	if [[ `uname` == Darwin ]]
	then ll_prefix='LC_TIME=en_US.UTF-8 '
	fi
	if command -v exa >/dev/null
	then alias ls=exa ll="${ll_prefix}exa --long --header" la='exa --all' tree='exa --tree'
	else alias ls='ls --color=auto' ll="${ll_prefix}ls -l --human-readable" la='ls --almost-all'
	fi
}

2>/dev/null source ~/.config/zsh/local-config.zsh
