#!/bin/bash

# WARNING: You don't need to edit this file!

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# shellcheck source=/dev/null
. "${SCRIPTPATH}/_library.sh"

parse_log() {
  FILE="$1"

  if [[ -n $FILE ]]; then
    COUNT_TEST=$(grep -c "\[TEST\]" "$FILE")
    COUNT_FAIL=$(grep -c "\[FAIL\]" "$FILE")
    COUNT_PASS=$(grep -c "\[PASS\]" "$FILE")
    COUNT_WARN=$(grep -c "\[WARN\]" "$FILE")

    echo -e "\n${CYAN}Tests: ${COUNT_TEST}${NC}, ${GREEN}Passed: ${COUNT_PASS}${NC}, ${RED}Failed: ${COUNT_FAIL}${NC}, ${YELLOW}Warnings: ${COUNT_WARN}${NC}"

    TESTS_WARN=$(grep -e "\[TEST\]" -e "\[WARN\]" "$FILE" | grep -e "\[WARN\]" -B 1 | grep -v -- "^--$")
    TESTS_FAIL=$(grep -e "\[TEST\]" -e "\[FAIL\]" "$FILE" | grep -e "\[FAIL\]" -B 1 | grep -v -- "^--$")

    if [[ $(( COUNT_FAIL + COUNT_WARN)) -gt 0 ]]; then
      echo -e "\nSummary of FAIL and WARN tests"
    fi

    if [[ ${COUNT_FAIL} -gt 0 ]] ; then
      echo -e "\n${TESTS_FAIL}"
    fi

    if [[ ${COUNT_WARN} -gt 0 ]] ; then
      echo -e "\n${TESTS_WARN}"
    fi
  else
    echo "No log file to parse found"
  fi
}

parse_log "$CAMUNDA_CHALLENGE_LOG_FILE"
