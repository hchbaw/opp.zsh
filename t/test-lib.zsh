#!zsh

((succ=0))
((fail=0))
((testn=0))
test_tmp_dir=".test-tmp"
CRLF=$'\r\n'

iseval () {
  local code="$1" xtracefile="$2"
  setopt localoptions no_ksharrays no_kshzerosubscript
  local output=
  local -i ret=0 xtracefd=-1
  {
    exec {xtracefd}>&2 2>| $xtracefile
    setopt localoptions xtrace
    eval "$code"
  } always {
    exec 2>&${xtracefd} {xtracefd}>&-
  }
}

is () {
  local xtracefile=${test_tmp_dir}/testxtrace
  ((testn++))
  if iseval "$1" $xtracefile; then
    ((succ++)); echo ok $testn >> ${test_tmp_dir}/testok
  else
    echo $testn failed, xtarce output:
    command cat $xtracefile
    ((fail++)); echo not ok $testn >> ${test_tmp_dir}/testok
  fi
}

test-run () {
  mkdir -p ${test_tmp_dir}
  {
    : >${test_tmp_dir}/testok
    local fun; for fun in ${@[@]}; do "$fun"; done
    echo 1..$testn
    command cat ${test_tmp_dir}/testok
  } always {
    rm -rf ${test_tmp_dir}
  }
}

with-zle-setup () {
  local line= tmp=
  zmodload zsh/zpty
  {
    zpty zle zsh -i -f
    zpty -w zle "source ./tzshrc"
    zpty -r zle line
    zpty -r zle line
    zw () { zpty -w zle "$1" }
    zr () { local tmp=; zpty -r zle tmp; zpty -r zle "$1" }
    "$@" zw zr
  } always {
    zpty -d zle
  }
}
