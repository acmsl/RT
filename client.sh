#!/bin/bash dry-wit
# Copyright 2013-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]] [-q|--quiet] init remote-url
$SCRIPT_NAME [-v[v]] [-q|--quiet] commit
$SCRIPT_NAME [-v[v]] [-q|--quiet] push
$SCRIPT_NAME [-h|--help]
(c) 2013-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Client script for RT.

- Init command: When setting up a new project, it prepares the project
to be able to commit and push changes remotely.
- Commit command: Commits any change to the internal repository.
- Push command: Pushes accumulated changes to the remote repository.
 
Where:
  * remote-url: The remote repository.
EOF
}
 
# Requirements
function checkRequirements() {
  checkReq git GIT_NOT_INSTALLED;
}
 
# Environment
function defineEnv() {
  export TEMPLATE_DEFAULT="value";
  export TEMPLATE_DESCRIPTION="A sample env variable";
  if    [ "${TEMPLATE+1}" != "1" ] \
     || [ "x${TEMPLATE}" == "x" ]; then
    export TEMPLATE="${TEMPLATE_DEFAULT}";
  fi

  ENV_VARIABLES=(\
    TEMPLATE \
  );
 
  export ENV_VARIABLES;
}

# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export GIT_NOT_INSTALLED="git not installed";
  export COMMAND_IS_MANDATORY="command is mandatory";
  export REMOTE_REPOSITORY_IS_MANDATORY="remote repository url is mandatory";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    GIT_NOT_INSTALLED \
    COMMAND_IS_MANDATORY \
    REMOTE_REPOSITORY_IS_MANDATORY \
  );

  export ERROR_MESSAGES;
}
 
# Checking input
function checkInput() {
 
  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logInfo -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      *) exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
 
  # Parameters
  if [ "x${COMMAND}" == "x" ]; then
    COMMAND="$1";
    shift;
  fi

  if [ "x${COMMAND}" == "x" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode COMMAND_IS_MANDATORY;
  fi
 
  if [ "${COMMAND}" == "init" ]; then
    if [ "x${REMOTE_REPOS}" == "x" ]; then
      REMOTE_REPOS="$1";
      shift;
    fi

    if [ "x${REMOTE_REPOS}" == "x" ]; then
      logInfoResult FAILURE "fail";
      exitWithErrorCode REMOTE_REPOSITORY_IS_MANDATORY;
    fi
  fi
}


# Calls mplayer and mencoder to perform a two-phase encoding in xdiv+mp3.
function main() {

}
