# vim's text-objects-ish for zsh.

# Author: Takeshi Banse <takebi@laafc.net>
# Licence: Public Domain

# Thank you very much, Bram Moolenaar!
# I want to use the vim's text-objects in zsh.

# To use this,
# 1) source this file.
# % source opp.zsh
#
# *Optionally* you can use the zcompiled file with the autoloading for a
# little faster loading on every shell startup, if you zcompile the
# necessary functions.
# *1) zcompile the defined functions and the install command.
# (generates ~/.zsh/zfunc/{opp,opp-install}.zwc)
# % O=~/path/to/opp.zsh; (zsh -c "source $O && opp-zcompile $O ~/.zsh/zfunc")
# *2) source the zcompiled install command file insted of this file.
# % source ~/.zsh/zfunc/opp-install; opp-install

# Note:
# This script replaces vicmd kepmap entries. Please beware of.

# Extension:

# opp/textobj-between.zsh
# http://d.hatena.ne.jp/thinca/20100614/1276448745
# http://d.hatena.ne.jp/tarao/20100715/1279185753
# Thank you very much, thinca and tarao!

# TODO: in case these (ci" with improper double quotes) situations.
# TODO: operator (currently c, d and y)
# TODO: o_v o_V o_CTRL_V
# TODO: as is op ip at it

# History

# v0.0.5
# Add opp/textobj-between.zsh
# Add `opp-installer-add' for the extentions.
# Add aw aW iW and fix iw.

# v0.0.4
# Add textobj-between link.

# v0.0.3
# Cleanup inbetween codes.

# v0.0.2
# Fix cc dd yy not work bug.

# v0.0.1
# Initial version.

# Code

bindkey -N opp

typeset -A opps; opps=()
opp_keybuffer=

opp-accept-p () {
  [[ $KEYS != *[0-9] ]]    && return 1
  [[ -n ${opps[$KEYS]-} ]] && return 0
  return -1
}

opp-undefined-key () {
  opp_keybuffer+=$KEYS
  opp-accept-p; local ret=$?
  ((ret == 0)) && zle .accept-line
  ((ret == 1)) && zle .send-break
}

def-oppc () {
  # an abbreviation of DEFine OPerator-Pending-mode-Command.
  # see also opp-recursive-edit
  local keys="$1"
  local funcname="${2-opp+$1}"
  bindkey -M opp "$keys" .accept-line
  opps+=("$keys" "$funcname")
}

def-opp-skip () {
  eval "$(cat <<EOT
    $1 () { while [[ \$BUFFER[((CURSOR$3))] == $4 ]] do ((CURSOR$2)) done }
EOT
  )"
}
def-opp-skip opp-skip-blank-backward   -- -0 "[[:blank:]]"
def-opp-skip opp-skip-blank-forward    ++ +1 "[[:blank:]]"
def-opp-skip opp-skip-alnum-backward   -- -0 "[[:alnum:]]"
def-opp-skip opp-skip-alnum-forward    ++ +1 "[[:alnum:]]"
def-opp-skip opp-skip-punct-backward   -- -0 "[[:punct:]]"
def-opp-skip opp-skip-punct-forward    ++ +1 "[[:punct:]]"
def-opp-skip opp-skip-alpunum-backward -- -0 "[[:alnum:][:punct:]]"
def-opp-skip opp-skip-alpunum-forward  ++ +1 "[[:alnum:][:punct:]]"

opp-generic-w () {
  zparseopts -D 1+:=fun1 2+:=fun2
  local beg end fun
  local -a fs; fs=(${=fun1})
  fs=(${=fun1}); for fun in ${fs:#-1}; do "$fun"; done; ((beg=$CURSOR))
  fs=(${=fun2}); for fun in ${fs:#-2}; do "$fun"; done; ((end=$CURSOR))
  "$@" $beg $end
}

def-oppc iw; opp+iw () {
  if [[ $BUFFER[((CURSOR+1))] == [[:blank:]] ]]; then
    opp-generic-w \
      -1 opp-skip-blank-backward \
      -2 opp-skip-blank-forward \
      -- \
      "$@"
  elif [[ $BUFFER[((CURSOR+1))] == [[:punct:]] ]]; then
    opp-generic-w \
      -1 opp-skip-punct-backward \
      -2 opp-skip-punct-forward \
      -- \
      "$@"
  else
    opp-generic-w \
      -1 opp-skip-alnum-backward \
      -2 opp-skip-alnum-forward \
      -- \
      "$@"
  fi
}

opp-skip-aw-forward-on-blank () {
  zle opp-skip-blank-forward
  if [[ $BUFFER[((CURSOR+1))] == [[:punct:]] ]]; then
    opp-skip-punct-forward
  else
    opp-skip-alnum-forward
  fi
}

def-oppc aw; opp+aw () {
  if [[ $BUFFER[((CURSOR+1))] == [[:blank:]] ]]; then
    opp-generic-w \
      -1 opp-skip-blank-backward \
      -2 opp-skip-aw-forward-on-blank \
      "$@"
  elif [[ $BUFFER[((CURSOR+1))] == [[:punct:]] ]]; then
    opp-generic-w \
      -1 opp-skip-punct-backward \
      -1 opp-skip-blank-backward \
      -2 opp-skip-blank-forward \
      -2 opp-skip-punct-forward \
      "$@"
  else
    opp-generic-w \
      -1 opp-skip-alnum-backward \
      -2 opp-skip-alnum-forward \
      -2 opp-skip-blank-forward \
      "$@"
  fi
}

def-oppc iW; opp+iW () {
  if [[ $BUFFER[((CURSOR+1))] == [[:blank:]] ]]; then
    opp-generic-w \
      -1 opp-skip-blank-backward \
      -2 opp-skip-blank-forward \
      "$@"
  else
    opp-generic-w \
      -1 opp-skip-alpunum-backward \
      -2 opp-skip-alpunum-forward \
      "$@"
  fi
}

def-oppc aW; opp+aW () {
  if [[ $BUFFER[((CURSOR+1))] == [[:space:]] ]]; then
    opp-generic-w \
      -1 opp-skip-blank-backward \
      -2 opp-skip-blank-forward \
      -2 opp-skip-alpunum-forward \
      "$@"
  else
    opp-generic-w \
      -1 opp-skip-alpunum-backward \
      -2 opp-skip-alpunum-forward \
      -2 opp-skip-blank-forward \
      "$@"
  fi
}

opp-generic () {
  local fix1="$1"; shift
  local fun1="$1"; shift
  local fix2="$1"; shift
  local fun2="$1"; shift
  local beg end
  [[ $fun1 != none ]] && zle $fun1; ((beg=$CURSOR $fix1))
  [[ $fun2 != none ]] && zle $fun2; ((end=$CURSOR $fix2))
  "$@" $beg $end
}

def-oppc-pair-1 () {
  local -a xs; : ${(A)xs::=${(s; ;)1}}
  local a=$xs[1]    # '('
  local b=$xs[2]    # ')'
  local c=${xs[3]-} # 'b' (optional)
  eval "$(cat <<EOT
    opp-fpcs-${(q)a} () { zle -U ${(q)a}; zle vi-find-prev-char-skip }
    opp-fnc-${(q)b}  () { zle -U ${(q)b}; zle vi-find-next-char      }
    zle -N opp-fpcs-${(q)a}
    zle -N opp-fnc-${(q)b}

    def-oppc i${(q)a}; def-oppc i${(q)b}; ${c:+def-oppc i${(q)c}}
    opp+i${(q)a} opp+i${(q)b} ${c:+opp+i${(q)c}} () {
      opp-generic \
        -0 opp-fpcs-${(q)a} \
        -0 opp-fnc-${(q)b} \
        "\$@"
    }
    def-oppc a${(q)a}; def-oppc a${(q)b}; ${c:+def-oppc a${(q)c}}
    opp+a${(q)a} opp+a${(q)b} ${c:+opp+a${(q)c}} () {
      opp-generic \
        -1 opp-fpcs-${(q)a} \
        +1 opp-fnc-${(q)b} \
        "\$@"
    }
EOT
  )"
}

def-oppc-pair () {
  local x; while read x; do
    [[ -n $x ]] && def-oppc-pair-1 $x
  done <<< "$1"
}

# XXX: 'k' stands for 'bracKet'. (my taste)
def-oppc-pair '
  [ ] k
  < >
  ( ) b
  { } B
'

def-oppc-inbetween-1 () {
  def-oppc-inbetween-2 "$1" "opp+i$s" "opp+a$s" oppc-inbetween-main
}

oppc-inbetween-main () {
  local s="$1"; shift
  zle -U "$s"
  "$@"
}

def-oppc-inbetween-2 () {
  local s="$1"
  local ifun="$2"
  local afun="$3"
  local proc="$4"
  eval "$(cat <<EOT
    def-oppc i${(q)s}; ${(q)ifun} () {
      $proc ${(q)s} \
        opp-generic \
          -0 vi-find-prev-char-skip \
          -1 vi-rev-repeat-find \
          "\$@"
    }
    def-oppc a${(q)s}; ${(q)afun} () {
      $proc ${(q)s} \
        opp-generic \
          -1 vi-find-prev-char-skip \
          -0 vi-rev-repeat-find \
          "\$@"
    }
EOT
  )"
}

def-oppc-inbetween () {
  local s; for s in "$@"; do
    def-oppc-inbetween-1 "$s"
  done
}

def-oppc-inbetween '"' "'" '`'

with-opp () {
  {
    zle -N undefined-key opp-undefined-key
    opp_keybuffer=$KEYS
    "$@" "$opp_keybuffer"
  } always {
    zle -N undefined-key opp-id # TODO: anything better?
  }
}

opp-linewise () {
  zle beginning-of-line
  zle set-mark-command
  zle end-of-line
  zle "$1"
}

opp-recursive-edit-1 () {
  local oppk="${1}"
  local fail="${2}"
  local succ="${3}"
  local   op="${4}"
  zle recursive-edit -K opp && {
    ${opps[$KEYS]} opp-k $oppk
    zle $succ
  } || {
    local arg=$opp_keybuffer[2,-1]
    [[ -n $arg ]] && {
      if [[ $arg == $op ]]; then
        opp-linewise $oppk
        zle $succ
      else
        zle -U "$arg"
        zle $fail
      fi
    }
  }
}

opp-recursive-edit () {
  with-opp opp-recursive-edit-1 "$@"
}; zle -N opp-recursive-edit

opp-k () {
  CURSOR="$2"
  zle set-mark-command
  CURSOR="$3"
  zle "$1"
}

opp-id () { "$@" }; zle -N opp-id

opp-copy-region () {
  zle copy-region-as-kill
  zle set-mark-command -n -1
}; zle -N opp-copy-region

opp-register-zle () {
  eval "$1 () { zle opp-recursive-edit -- $2 $3 $4 }; zle -N $1"
}

opp-register-zle opp-vi-change kill-region vi-change vi-insert
opp-register-zle opp-vi-delete kill-region vi-delete opp-id
opp-register-zle opp-vi-yank opp-copy-region vi-yank opp-id

# Entry point.
typeset -gA opp_operators; opp_operators=()
opp () {
  # to implement autoloading easier,
  # all of the operator commands will be dispatched through this func.
  opp1
}
opp1 () { $opp_operators[$KEYS]; }

opp-install () {
  {
    zle -N opp opp
    typeset -gA opp_operators; opp_operators=()
    BK () {
      opp_operators+=("$1" $2)
      bindkey -M vicmd "$1" opp
      { bindkey -M afu-vicmd "$1" opp } > /dev/null 2>&1
    }
    BK "c" opp-vi-change
    BK "d" opp-vi-delete
    BK "y" opp-vi-yank
    { "$@" }
  } always {
    unfunction BK
  }
}
opp-install

# zcompiling code.

opp-clean () {
  local d=${1:-~/.zsh/zfunc}
  rm -f ${d}/{opp,opp.zwc*(N)}
  rm -f ${d}/{opp-install,opp-install.zwc*(N)}
}

opp-install-installer () {
  local match mbegin mend
  eval ${${${"$(<=(cat <<"EOT"
    opp-install-after-load () {
      typeset -g opp_keybuffer
      bindkey -N opp
      { $opp_installer_codes }
      { $body }
      opp_loaded_p=t
    }
    opp-install-maybe () {
      [[ -z ${opp_loaded_p-} ]] || return
      opp-install-after-load
    }
    # redefine opp
    opp () {
      opp-install-maybe
      opp1
    }
EOT
  ))"}/\$body/
  $(print -l \
    "# opp's zle widget" \
    ${${(M)${(@f)"$(zle -l)"}:#(opp*)}/(#b)(*)/zle -N ${(qqq)match}} \
    "# bindkeys on the opp keymap" \
    ${(q@f)"$(bindkey -M opp -L)"})
  }/\$opp_installer_codes/$(opp-installer-expand)}
}

opp_installer_codes=()

opp-installer-add () { opp_installer_codes+=($1) }

opp-installer-expand () {
  local c; for c in $opp_installer_codes; do
    "$c"
  done
}

opp-installer-install-opps () {
  echo ${"$(typeset -p opps)"/typeset -A/typeset -gA}
}; opp-installer-add opp-installer-install-opps

opp-zcompile () {
  #local opp_zcompiling_p=t
  local s=${1:?Please specify the source file itself.}
  local d=${2:?Please specify the directory for the zcompiled file.}
  emulate -L zsh
  setopt extended_glob no_shwordsplit

  echo "** zcompiling opp in ${d} for a little faster startups..."
  [[ -n ${OPP_PARANOID-} ]] && {
    echo "* reloading ${s}"
    source ${s} >/dev/null 2>&1
  }
  echo "mkdir -p ${d}" | sh -x
  opp-clean ${d}
  opp-install-installer

  local g=${d}/opp
  echo "* writing code ${g}"
  {
    local -a fs
    : ${(A)fs::=${(Mk)functions:#(*opp*)}}
    echo "#!zsh"
    echo "# NOTE: Generated from opp.zsh ($0). Please DO NOT EDIT."; echo
    local -a es; es=('def-*' '*register*' 'opp-installer-*' \
      opp-clean opp-install-installer opp-zcompile opp-install)
    echo "$(functions ${fs:#${~${(j:|:)es}}})"
    echo "\nopp"
  }>! ${g}

  local gi=${d}/opp-install
  echo "* writing code ${gi}"
  {
    echo "#!zsh"
    echo "# NOTE: Generated from opp.zsh ($0). Please DO NOT EDIT."; echo
    echo "$(functions opp-install)"
  }>! ${gi}

  [[ -z ${OPP_NOZCOMPILE-} ]] || return
  autoload -U zrecompile && {
    Z () { echo -n "* "; zrecompile -p -R "$1" }; Z ${g} && Z ${gi}
  } && {
    zmodload zsh/datetime
    touch --date="$(strftime "%F %T" $((EPOCHSECONDS + 10)))" {${g},${gi}}.zwc
    [[ -z ${OPP_ZCOMPILE_NOKEEP-} ]] || { echo "rm -f ${g} ${gi}" | sh -x }
    echo "** All done."
    echo "** Please update your .zshrc to load the zcompiled file like this,"
    cat <<EOT
-- >8 --
## opp.zsh stuff.
# source ${s/$HOME/~}
{ . ${gi/$HOME/~}; opp-install; }
-- 8< --
EOT
  }
}
