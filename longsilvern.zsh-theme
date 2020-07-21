declare GIT_PROMPT_BEHIND="%{$fg[red]%}⇣"
declare GIT_PROMPT_DIRTY="%{$fg[yellow]%}*"
declare GIT_PROMPT_AHEAD="%{$fg[green]%}⇡"
declare GIT_PROMPT_CLEAN="%{$reset_color%}"

function checkGitStatus() {
    declare STATUS="$GIT_PROMPT_CLEAN"

    if [[ -n $(git log origin/$(git_current_branch)..HEAD 2> /dev/null) ]]; then
        STATUS+="$GIT_PROMPT_AHEAD"
    fi

    if [[ -n $(git status -s) ]]; then
        STATUS+="$GIT_PROMPT_DIRTY"
    fi

    if [[ -n $(git log HEAD..origin/$(git_current_branch) 2> /dev/null) ]]; then
        STATUS+="$GIT_PROMPT_BEHIND"
    fi

    echo "$STATUS"
}

# Show execution time after each command
function preexec() {
  timer=$(( $(date +%s) ))
}

function precmd() {
  if [ $timer ]; then
    now=$(( $(date +%s) ))
    elapsedSecs=$(( $now-$timer ))
    unset timer

    declare EXECUTION_COLOUR="%{$fg[green]%}"
    # Only show execution time if more than 1 second
    if [[ "$elapsedSecs" -gt 1 ]]; then
        TIME_STRING="${elapsedSecs}s"
        declare -i hours
        declare -i mins
        declare -i secs

        # Yellow colour warning where execution is longer than 1 minute
        if [[ "$elapsedSecs" -ge 60 ]] && [[ "$elapsedSecs" -le 300 ]]; then
            EXECUTION_COLOUR="%{$fg[yellow]%}"
            mins=$(( $elapsedSecs%3600/60 ))
            secs=$(( $elapsedSecs%60 ))
            TIME_STRING="${mins}m${secs}s"
        fi

        # Red colour warning where execution is longer than 5 minutes
        if [[ "$elapsedSecs" -gt 300 ]]; then
            EXECUTION_COLOUR="%{$fg[red]%}"
        fi

        if [[ "$elapsedSecs" -ge 3600 ]]; then
            hours=$(( $elapsedSecs/3600 ))
            TIME_STRING="${hours}h${mins}m${secs}s"
        fi

        RPROMPT="$EXECUTION_COLOUR$TIME_STRING %{$reset_color%}"
    else
        RPROMPT=""
    fi

    export RPROMPT
  fi
}

#------------------- PROMPT ---------------------
function timeStampPrompt() {
    echo "%{$fg_bold[grey]%}%T|%{$reset_color%}"
}

# If the path contains more than 4 directories, omit the middle path using ellipsis
function compactPathPrompt() {
    declare maximumElements=4
    declare displayElements=2
    echo "%{$fg[cyan]%}%($maximumElements~|%-1~/…/%$displayElements~|%$((DISPLAY_ELEMENTS++))~)%{$reset_color%}"
}

declare GIT_PROMPT_PREFIX="%{$fg[blue]%}⦗"
declare GIT_PROMPT_SUFFIX="%{$fg[blue]%}⦘%{$reset_color%}"

function gitStatusPrompt() {
    if $(git rev-parse --is-inside-work-tree 2>/dev/null); then
        # Compact the branch name when it is longer than maxinum length
        max_branch_name_length=15
        echo "$GIT_PROMPT_PREFIX%$max_branch_name_length>…>$(checkGitStatus)$(git_current_branch)%>>$GIT_PROMPT_SUFFIX"
    else
        echo ""
    fi
}

PROMPT='$(timeStampPrompt)$(compactPathPrompt) $(gitStatusPrompt) '
PROMPT+='%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜) '
