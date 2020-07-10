GIT_PROMPT_BEHIND="%{$fg[red]%}⇣"
GIT_PROMPT_DIRTY="%{$fg[yellow]%}*"
GIT_PROMPT_AHEAD="%{$fg[green]%}⇡"
GIT_PROMPT_CLEAN="%{$reset_color%}"

GIT_PROMPT_PREFIX="%{$fg[blue]%}⦗"   #git symbol \uE0A0
GIT_PROMPT_SUFFIX="%{$fg[blue]%}⦘%{$reset_color%} "

function gitCheckStatus() {
    if [[ -n $(git status -s) ]]; then
        echo "$GIT_PROMPT_DIRTY"
    elif [[ -n $(git log HEAD..origin/$(git_current_branch) 2> /dev/null) ]]; then
        echo "$GIT_PROMPT_BEHIND"
    elif [[ -n $(git log HEAD..origin/$(git_current_branch) 2> /dev/null) ]]; then
        echo "$GIT_PROMPT_BEHIND"
    else
        echo "$GIT_PROMPT_CLEAN"
    fi
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

#‹›
function timeStamp() {
    echo "%{$fg_bold[grey]%}%T|%{$reset_color%}"
}

# If the path is too long, omit the middle path using ellipsis
function compactPath() {
    maximumElements=4
    displayElements=2
    echo "%{$fg[yellow]%}%($maximumElements~|%-1~/…/%$displayElements~|%$((DISPLAY_ELEMENTS++))~)%{$reset_color%}"
}

 
#------------------- PROMPT ---------------------
PROMPT='$(timeStamp)$(compactPath) $(gitStatus)'


PROMPT+='%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜) '
