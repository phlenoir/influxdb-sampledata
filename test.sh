#!/bin/bash
set -i
HISTFILE=~/.myscript.history
history -c
history -r

TEST_MENU_ENTRY=()
TEST_NAME=()
TEST_DESCR=()

myread() {
    read -e -p '> ' $1
    history -s ${!1}
}
trap 'history -a;exit' 0 1 2 3 6

load_list() {
  # load list of test suites
  for i in ./*-test.sh; do
    s=${i##*/}
    short="${s:0:2}"
    TEST_MENU_ENTRY=("${TEST_MENU_ENTRY[@]}" "${short}")
    TEST_NAME=("${TEST_NAME[@]}" "${s}")
    while read line_in_file; do
        [[ $line_in_file =~ TEST_SUITE_NAME= ]] && TEST_DESCR=("${TEST_DESCR[@]}" "${line_in_file##*=}") && break
    done < $i
  done
}

print_menu() {
  echo "Test suite launcher menu"
  paste -d ' ' <(printf "    %s :\n" "${TEST_MENU_ENTRY[@]}") <(printf "run '%s'\n" "${TEST_NAME[@]}") <(printf "%s\n" "${TEST_DESCR[@]}")
  echo "  exit : quit the test suite launcher"
}

load_list
while myread line;do
    case ${line%% *} in
      exit )
        break
      ;;
      * )
        for ((i = 0; i < ${#TEST_MENU_ENTRY[@]}; i++)); do
          if [[ ${TEST_MENU_ENTRY[$i]} = $line ]]; then
            paste -d ' ' <(printf "Running '%s'\n" "${TEST_NAME[$i]}") <(printf "%s\n" "${TEST_DESCR[$i]}")
            ./${TEST_NAME[$i]}
            break
          fi
        done
        if [[ $i = ${#TEST_MENU_ENTRY[@]} ]]; then
          print_menu
        fi
      ;;
    esac
done
