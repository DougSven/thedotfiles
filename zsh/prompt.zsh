autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_not_added() {
  expr $(git status --porcelain 2>/dev/null| grep "^ M" | wc -l)
}

git_not_committed() {
  expr $(git status --porcelain 2>/dev/null| grep "^M" | wc -l)
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    # Get number of files that are uncommitted and not added
    if [[ $(git_not_added) > 0 ]]; then
      echo " %{$fg[magenta]%}$(git_prompt_info)%{$reset_color%} %{$fg_bold[red]%}◎%{$reset_color%}"
    elif [[ $(git_not_committed) > 0 ]]; then
      echo " %{$fg[magenta]%}$(git_prompt_info)%{$reset_color%} %{$fg_bold[yellow]%}◉%{$reset_color%}"
      #statements
    else
      echo " %{$fg[magenta]%}$(git_prompt_info)%{$reset_color%} %{$fg_bold[green]%}✪%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{origin} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " %{$fg_bold[magenta]%}☠%{$reset_color%} "
  fi
}

ruby_version() {
  if (( $+commands[rbenv] ))
  then
    echo "$(rbenv version | awk '{print $1}')"
  fi

  if (( $+commands[rvm-prompt] ))
  then
    echo "$(rvm-prompt | awk '{print $1}')"
  fi
}

rb_prompt() {
  if ! [[ -z "$(ruby_version)" ]]
  then
    echo "%{$fg_bold[yellow]%}$(ruby_version)%{$reset_color%} "
  else
    echo ""
  fi
}

directory_name() {
  echo "%{$fg[cyan]%}%1/%\%{$reset_color%}"
}

export PROMPT=$'$(directory_name)$(git_dirty)$(need_push)%{$fg[cyan]%}❖%{$reset_color%} '
set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
