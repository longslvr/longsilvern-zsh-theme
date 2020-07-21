declare GIT_PROMPT_BEHIND="%{$fg[red]%}⇣"
declare GIT_PROMPT_DIRTY="%{$fg[yellow]%}*"
declare GIT_PROMPT_AHEAD="%{$fg[green]%}⇡"
declare GIT_PROMPT_CLEAN="%{$reset_color%}"

declare GIT_PROMPT_PREFIX="%{$fg[blue]%}⦗"
declare GIT_PROMPT_SUFFIX="%{$fg[blue]%}⦘%{$reset_color%}"

function gitCheckStatus() {
    declare STATUS="$GIT_PROMPT_CLEAN"

    if [[ -n $(git status -s) ]]; then
        STATUS="$GIT_PROMPT_DIRTY"
    fi

    if [[ -n $(git log origin/$(git_current_branch)..HEAD 2> /dev/null) ]]; then
        STATUS="$GIT_PROMPT_AHEAD"
    fi

    if [[ -n $(git log HEAD..origin/$(git_current_branch) 2> /dev/null) ]]; then
        STATUS="$GIT_PROMPT_BEHIND"
    fi

    echo "$STATUS"
}

function gitStatus() {
    if $(git rev-parse --is-inside-work-tree 2>/dev/null); then
        # compact the branch name when it is too long
        max_branch_name_length=15
        echo "$GIT_PROMPT_PREFIX%$max_branch_name_length>…>$(gitCheckStatus)$(git_current_branch)%>>$GIT_PROMPT_SUFFIX"
    else
        echo ""
    fi
}

function timeStamp() {
    echo "%{$fg_bold[grey]%}%T|%{$reset_color%}"
}

# If the path is too long, omit the middle path using ellipsis
function compactPath() {
    declare maximumElements=4
    declare displayElements=2
    echo "%{$fg[cyan]%}%($maximumElements~|%-1~/…/%$displayElements~|%$((DISPLAY_ELEMENTS++))~)%{$reset_color%}"
}

# Show execution time after each command
function preexec() {
  timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
  if [ $timer ]; then
    now=$(($(date +%s%0N)/1000000))
    elapsedMs=$(($now-$timer))

    declare EXECUTION_COLOUR="%{$fg[green]%}"
    if [[ "$elapsedMs" -gt 5000 ]]; then
        elapsedS=$(($elapsedMs / 1000))

        EXECUTION_COLOUR="%{$fg[yellow]%}"
        export RPROMPT="$EXECUTION_COLOUR${elapsedS}s %{$reset_color%}"
    else
        export RPROMPT="$EXECUTION_COLOUR${elapsedMs}ms %{$reset_color%}"
    fi
    unset timer
  fi
}

#------------------- PROMPT ---------------------
PROMPT='$(timeStamp)$(compactPath) $(gitStatus) '


PROMPT+='%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜) '
