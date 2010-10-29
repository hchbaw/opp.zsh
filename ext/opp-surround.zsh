
# TODO: these opp-ids!!!
# TODO: these linewise detection!!! ysiw broken!!!

# TODO: see, below
# (opp_sopps+=(y opp-surround+y) # TODO: link this key 'y' <=> def-oppc's 'y')
opp_surround_opp=
def-oppc s opp+surround; opp+surround () {
  local op="$opp_keybuffer"
  {
    opp_surround_opp=${opp_surround_opp:-$op}
    [[ $op == 'y' ]] && {
      zle opp-recursive-edit opp-id opp-id opp-id; ((REGION_ACTIVE==1)) \
      && { opp-s-read $opp_surround_opp opp-surround }
    } || [[ -n $opp_surround_opp ]] \
      && { opp-s-read $opp_surround_opp opp-surround }
  } always {
    opp_surround_opp=
    zle set-mark-command -n -1
    zle -R
  }
}

opp-s-read () {
  local   op="$1"; shift
  local succ="$1"; shift
  opp-s-read-acc () {
    local c="$1"
    [[ $c == "" ]] && return -255 # XXX: see opp-s-loop
    [[ $c != [[:print:]] ]] && return 0
    : ${(P)2::=$3$1}
    return -1
  }
  opp-s-reading () { zle -R "${1[1]}s" }
  opp-s-read-1 "$op" opp-s-read-acc "$succ" opp-s-read-fail opp-s-reading "$@"
}

opp-s-read-1 () {
  local   op="$1"; shift
  local pred="$1"; shift
  local succ="$1"; shift
  local fail="$1"; shift
  local mess="$1"; shift

  echo "**"
  echo $opp_keybuffer
  echo "**#:"

  # TODO: linewise for 'y'
  # TODO: remove this 'y'
  [[ $op == 'y' ]] && [[ $opp_keybuffer == 's' ]] && {
    opp-s-read "linewise" opp-surround
    return 0
  }
  [[ $op != 'c' ]] && [[ $op != 'd' ]] && {
    "$mess" $op
  }
  local c; read -s -k 1 c
  # TODO: remove this 'd' and 'c'. 's', too if possible.
  [[ $op == 'd' ]] && [[ $c == 's' ]] && return -1
  [[ $op == 'c' ]] && [[ $c == 's' ]] && {
    opp-s-read "linewise" opp-surround
    return 0
  }
  opp-s-loop \
    "$op" \
    '${(@k)opp_surrounds}' \
    "$c" \
    "$pred" \
    '' \
    0 \
    "$succ" \
    "$fail" \
    "$mess" \
    "$@"
}

opp-s-loop () {
  local o="$1"
  local e="$2"; local -a ks; { eval "ks=($e)" }
  local c="$3"
  local p="$4"
  local a="$5"; "$p" "$c" a "$a"; local -i r=$?
  local f="$6"
  local succ="$7"
  local fail="$8"
  local mess="$9"
  shift 9 # At this point "$@" indicates refering the &rest argment.

  ((r==-255)) && { return -1 }

  "$mess" "$o" "$a" "$@"

  local -i n0; ((n0=${#${(@M)ks:#${a}}} ))
  local -i n1; ((n1=${#${(@M)ks:#${a}*}}))

  opp-s-loop-1 () {
    local fn="$1"; shift
    "$fn" $o $e "$c" $p "$a" $f $succ $fail $mess "$@"
  }

  ((n0==1)) && ((r ==0)) &&              {"$succ" "$o" "$a" "$@"; return 0} ||
  ((n0==1)) && ((n1==1)) &&              {"$succ" "$o" "$a" "$@"; return 0} ||
  ((n1==0)) && ((r ==0)) && ((f ==1)) && {"$succ" "$o" "$a" "$@"; return 0} ||
  ((n1==0)) && {   opp-s-loop-1    "$fail" "$@"; return -1                } ||
  { read -s -k 1 c;opp-s-loop-1 opp-s-loop "$@"; return  0}
}

opp-s-read-fail () {
  local o="$1"
  local e="$2"; local -a ks; { eval "ks=($e)" }
  local c="$3"
  local p="$4"
  local a="$5"
  local f="$6"
  local succ="$7"
  local fail="$8"
  local mess="$9"
  shift 9 # At this point "$@" indicates refering the &rest argment.

  # TODO: Add an appropriate code for editing the command line.
  # XXX: Embeded the tag code for the place-holder purpose.
  opp-s-read-acc-tagish () {
    local c="$1"
    [[ $c == "" ]] && return -255 # XXX: see opp-s-loop
    : ${(P)2::=$3$1}
    [[ $c == '>' ]] && return 0
    return -1
  }
  opp-surround-tagish () {
    local o="$1"
    local tag1="$2"
    local tag2="</$tag1[2,-1]"
    shift 2
    [[ -z ${1-} ]] && [[ -z ${2-} ]] && {
      "$opp_sopps[$o]" "$tag1" "$tag2"
    } || {
      opp-s-wrap-maybe $1 $2 $tag1 $tag2
    }
  }

  read -s -k 1 c
  opp-s-loop  $o $e "$c" \
    opp-s-read-acc-tagish "$a" 1 opp-surround-tagish $fail $mess "$@"
}

#succ fail () { echo "$0 \`$@'" }
#opp-s-loop d '(a aa b)' a opp-s-read-accept-force-p '' succ fail

# TODO: add syntax abstraction.
typeset -A opp_surrounds; opp_surrounds=()
opp_surrounds+=(\" opp+surround\"); opp+surround\" () { reply=('""' '""') }
opp_surrounds+=(\"\" opp+surround\"\"); opp+surround\"\" () { reply=('"">' '<""') }
opp_surrounds+=(\' opp+surround\'); opp+surround\' () { reply=('>>' '<<') }

# TODO: add syntax abstraction.
typeset -A opp_sopps; opp_sopps=()
opp_sopps+=(linewise opp-surround+linewise)
opp_sopps+=(y opp-surround+y) # TODO: link this key 'y' <=> def-oppc's 'y'
opp_sopps+=(d opp-surround+d)
opp_sopps+=(c opp-surround+c)

opp-surround () {
  local o="$1"
  local k="$2"
  local -a cell; opp-s-ref $opp_surrounds[$k] cell
  "$opp_sopps[$o]" "$cell[1]" "$cell[2]"
}

opp-s-ref () {
  local ebody=$1
  local place=$2
  local -a reply; "$ebody"; eval "$place=('$reply[1]' '$reply[2]')"
}

opp-surround+linewise () {
  BUFFER="$1"$BUFFER"$2"
}

opp-surround+y () {
  RBUFFER="${2}${RBUFFER}"
  zle exchange-point-and-mark
  LBUFFER="${LBUFFER}${1}"
  zle set-mark-command -n -1
  ((CURSOR--))
}

opp-surround+d () {
  opp-s-wrap-maybe "$1" "$2" '' ''
}

opp-surround+c () {
  opp-s-read "c" opp-surround+c-1 "$@"
}

opp-surround+c-1 () {
  shift
  local k="$1"
  local s1="$2"
  local s2="$3"
  local -a cell; opp-s-ref "$opp_surrounds[$k]" cell
  opp-s-wrap-maybe $s1 $s2 $cell[1] $cell[2]
}

opp-s-wrap-maybe () {
  local s1="$1"
  local s2="$2"
  local t1="$3"
  local t2="$4"
  local fail="${5-opp-s-fail}"
  [[ $RBUFFER == *${s2}* ]] && [[ $LBUFFER == *${s1}* ]] && {
    [[ $RBUFFER == *${s2}* ]] && {
      local -i k=${(BS)RBUFFER#${s2}*}
      CURSOR+=k; ((CURSOR--))
      zle set-mark-command
      CURSOR+=${#s2}
      zle kill-region
      RBUFFER=${t2}$RBUFFER
    }
    [[ $LBUFFER == *${s1}* ]] && {
      local -i k=${(BS)LBUFFER%${s1}*}
      CURSOR=k; ((CURSOR--))
      zle set-mark-command
      CURSOR+=${#s1}
      zle kill-region
      LBUFFER=$LBUFFER${t1}
    }
  } || {
    return -1
  }
}
