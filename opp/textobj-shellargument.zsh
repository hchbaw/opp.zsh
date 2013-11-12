# text-objects for arguments using split-shell-arguments

def-oppc ix; opp+ix () { opp-ts "$@" }
def-oppc ax; opp+ax () { opp-ts "$@" } #TODO should fix `a`s in general

opp-ts () {
  autoload -Uz split-shell-arguments
  setopt no_ksharrays
  local -a reply
  local REPLY REPLY2
  split-shell-arguments
  "$@" ${#${(j..)reply[1,REPLY-1]}} ${#${(j..)reply[1,REPLY]}}
}
