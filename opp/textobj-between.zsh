# textobj-between code for opp.zsh.

# Author Takeshi Banse <takebi@laafc.net>
# Licence: Public Domain

# Thank you very much, thinca and tarao!
#
# http://d.hatena.ne.jp/thinca/20100614/1276448745
# http://d.hatena.ne.jp/tarao/20100715/1279185753

def-oppc-textobj-between () {
  def-oppc-inbetween-2 "$1" "opp+i$1" "opp+a$1" oppc-tb-main
}

oppc-tb-main () {
  shift
  local c; read -s -k 1 c
  [[ "$c" == [[:print:]] ]] || return
  zle -U "$c"
  "$@"
}

def-oppc-textobj-between 'F'
