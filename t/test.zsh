#!zsh

. ./test-lib.zsh

test-word-aux () {
  local zw="$1" zr="$2"
  local line=
  $zw "echo word"$'\eciwnewword'
  $zr line; is '[[ $line == newword$CRLF ]]'

  $zw "echo word_word"$'\eciwnewword'
  $zr line; is '[[ $line == newword$CRLF ]]'

  $zw "echo word_word"$'\eF_ciwnewword'
  $zr line; is '[[ $line == newword$CRLF ]]'
}
test-word () { with-zle-setup test-word-aux }

test-run test-word
