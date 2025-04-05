# https://github.com/junegunn/fzf/blob/master/shell/key-bindings.bash

[[ ! $- =~ i ]] && return 0

if command -v perl > /dev/null; then

	__fzf_history__() {
		local output opts script
		opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
		script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
		output=$(
			set +o pipefail
			builtin fc -lnr -2147483648 |
				last_hist=$(HISTTIMEFORMAT='' builtin history 1) command perl -n -l0 -e "$script" |
				FZF_DEFAULT_OPTS="$opts" fzf --query "$READLINE_LINE"
		) || return
		READLINE_LINE=${output#*$'\t'}
		if [[ -z $READLINE_POINT ]]; then
			echo "$READLINE_LINE"
		else
			READLINE_POINT=0x7fffffff
		fi
	}

else

	echo "perl required"
	exit 1

	# # awk - fallback for POSIX systems
	# __fzf_history__() {
	# 	local output opts script n x y z d
	# 	if [[ -z $__fzf_awk ]]; then
	# 		__fzf_awk=awk
	# 		# choose the faster mawk if: it's installed && build date >= 20230322 && version >= 1.3.4
	# 		IFS=' .' read -r n x y z d <<< $(command mawk -W version 2> /dev/null)
	# 		[[ $n == mawk ]] && ((d >= 20230302 && (x * 1000 + y) * 1000 + z >= 1003004)) && __fzf_awk=mawk
	# 	fi
	# 	opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
	# 	[[ $(HISTTIMEFORMAT='' builtin history 1) =~ [[:digit:]]+ ]] # how many history entries
	# 	script='function P(b) { ++n; sub(/^[ *]/, "", b); if (!seen[b]++) { printf "%d\t%s%c", '$((BASH_REMATCH + 1))' - n, b, 0 } }
	#    NR==1 { b = substr($0, 2); next }
	#    /^\t/ { P(b); b = substr($0, 2); next }
	#    { b = b RS $0 }
	#    END { if (NR) P(b) }'
	# 	output=$(
	# 		set +o pipefail
	# 		builtin fc -lnr -2147483648 2> /dev/null | # ( $'\t '<lines>$'\n' )* ; <lines> ::= [^\n]* ( $'\n'<lines> )*
	# 			command $__fzf_awk "$script" |            # ( <counter>$'\t'<lines>$'\000' )*
	# 			FZF_DEFAULT_OPTS="$opts" fzf --query "$READLINE_LINE"
	# 	) || return
	# 	READLINE_LINE=${output#*$'\t'}
	# 	if [[ -z $READLINE_POINT ]]; then
	# 		echo "$READLINE_LINE"
	# 	else
	# 		READLINE_POINT=0x7fffffff
	# 	fi
	# }

fi

# Required to refresh the prompt after fzf
bind -m emacs-standard '"\er": redraw-current-line'

bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
# bind -m emacs-standard '"\C-z": vi-editing-mode'

if ((BASH_VERSINFO[0] < 4)); then

	bind -m emacs-standard '"\C-f": "\C-e \C-u\C-y\ey\C-u`__fzf_history__`\e\C-e\er"'
	bind -m vi-command '"\C-f": "\C-z\C-f\C-z"'
	bind -m vi-insert '"\C-f": "\C-z\C-f\C-z"'

else

	bind -m emacs-standard -x '"\C-f": __fzf_history__'
	bind -m vi-command -x '"\C-f": __fzf_history__'
	bind -m vi-insert -x '"\C-f": __fzf_history__'
fi
