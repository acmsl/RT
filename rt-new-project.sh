#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
    cat <<EOF
$SCRIPT_NAME [-v[v]] [-q|--quiet] project projectDir
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Sets up a RT repository for a new project.

Where:
  * project: The project.
  * projectDir: The local checkout of the project.
EOF
}

# Requirements
function checkRequirements() {
    checkReq git GIT_NOT_INSTALLED;
}

# Environment
function defineEnv() {
    export GITHUB_USERNAME_DEFAULT="rydnr";
    export GITHUB_USERNAME_DESCRIPTION="The github username";
    if    [ "${GITHUB_USERNAME+1}" != "1" ] \
       || [ "x${GITHUB_USERNAME}" == "x" ]; then
        export GITHUB_USERNAME="${GITHUB_USERNAME_DEFAULT}";
    fi
    
    export DEFAULT_FILE_DEFAULT=".README.md.rt";
    export DEFAULT_FILE_DESCRIPTION="The commit messag";
    if    [ "${DEFAULT_FILE+1}" != "1" ] \
       || [ "x${DEFAULT_FILE}" == "x" ]; then
        export DEFAULT_FILE="${DEFAULT_FILE_DEFAULT}";
    fi
    
    export COMMIT_MESSAGE_DEFAULT="Initial commit";
    export COMMIT_MESSAGE_DESCRIPTION="The commit messag";
    if    [ "${COMMIT_MESSAGE+1}" != "1" ] \
       || [ "x${COMMIT_MESSAGE}" == "x" ]; then
        export COMMIT_MESSAGE="${COMMIT_MESSAGE_DEFAULT}";
    fi
    
    export BASHRC_ALIAS_FILE_DEFAULT="${HOME}/.bashrc-aliases";
    export BASHRC_ALIAS_FILE_DESCRIPTION="The file to append the BASH alias";
    if    [ "${BASHRC_ALIAS_FILE+1}" != "1" ] \
       || [ "x${BASHRC_ALIAS_FILE}" == "x" ]; then
        export BASHRC_ALIAS_FILE="${BASHRC_ALIAS_FILE_DEFAULT}";
    fi
    
    export RT_PROJECTS_FILE_DEFAULT="${HOME}/.rt-projects";
    export RT_PROJECTS_FILE_DESCRIPTION="The file where the RT projects are listed";
    if    [ "${RT_PROJECTS_FILE+1}" != "1" ] \
       || [ "x${RT_PROJECTS_FILE}" == "x" ]; then
        export RT_PROJECTS_FILE="${RT_PROJECTS_FILE_DEFAULT}";
    fi
    
    export RT_GIT_DIR_DEFAULT="${HOME}/.RT.git.d";
    export RT_GIT_DIR_DESCRIPTION="The RT basefolder";
    if    [ "${RT_GIT_DIR+1}" != "1" ] \
       || [ "x${RT_GIT_DIR}" == "x" ]; then
        export RT_GIT_DIR="${RT_GIT_DIR_DEFAULT}";
    fi
    
    ENV_VARIABLES=(\
        GITHUB_USERNAME \
        COMMIT_MESSAGE \
        DEFAULT_FILE \
        BASHRC_ALIAS_FILE \
        RT_PROJECTS_FILE \
        RT_GIT_DIR \
    );
    
    export ENV_VARIABLES;
}

# Error messages
function defineErrors() {
    export INVALID_OPTION="Unrecognized option";
    export GIT_NOT_INSTALLED="git not installed";
    export PROJECT_IS_MANDATORY="project is mandatory";
    export PROJECT_DIR_IS_MANDATORY="project is mandatory";
    export INVALID_COMMAND="Invalid command";
    export CANNOT_SETUP_GIT_REPOSITORY="Cannot add files";
    export CANNOT_ADD_REMOTE_REPOSITORY="Cannot add the remote repository";
    export CANNOT_ADD_FILES="Cannot add files";
    export CANNOT_COMMIT_CHANGES="Cannot commit changes";
    export CANNOT_PUSH_CHANGES="Cannot push changes";
    export CANNOT_ADD_BASHRC_ALIAS_TO_FILE="Cannot add Bash alias";
    export CANNOT_ADD_RT_PROJECT_TO_FILE="Cannot add the project to the RT projects file";

    ERROR_MESSAGES=(\
        INVALID_OPTION \
        GIT_NOT_INSTALLED \
        PROJECT_IS_MANDATORY \
        PROJECT_DIR_IS_MANDATORY \
        INVALID_COMMAND \
        CANNOT_SETUP_GIT_REPOSITORY \
        CANNOT_ADD_REMOTE_REPOSITORY \
        CANNOT_ADD_FILES \
        CANNOT_COMMIT_CHANGES \
        CANNOT_PUSH_CHANGES \
        CANNOT_ADD_BASHRC_ALIAS_TO_FILE \
        CANNOT_ADD_RT_PROJECT_TO_FILE \
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
    if [ "x${PROJECT}" == "x" ]; then
        PROJECT="$1";
        shift;
    fi

    if [ "x${PROJECT}" == "x" ]; then
        logInfoResult FAILURE "failed";
        exitWithErrorCode PROJECT_IS_MANDATORY;
    fi
    
    if [ "x${PROJECT_DIR}" == "x" ]; then
        PROJECT_DIR="$1";
        shift;
    fi

    if [ "x${PROJECT_DIR}" == "x" ]; then
        logInfoResult FAILURE "failed";
        exitWithErrorCode PROJECT_DIR_IS_MANDATORY;
    fi
    
    logInfoResult SUCCESS "valid";
}

function retrieveRemoteRepos() {

    local _project="${1}";
    export RESULT="https://github.com/${GITHUB_USERNAME}/.${_project}.rt";
}

function main() {

    local _remoteRepos;    
    local _folder;

    retrieveRemoteRepos "${PROJECT}";
    _remoteRepos="${RESULT}";
    createTempFolder;
    _folder="${RESULT}";

    git_init "${_folder}" "${_remoteRepos}";
    git_add "${_folder}";
    git_commit "${_folder}";
    git_push "${_folder}";
    add_bashrc_alias "${PROJECT}" "${PROJECT_DIR}" "${BASHRC_ALIAS_FILE}";
    add_rt_project "${PROJECT}" "${RT_PROJECTS_FILE}";
    show_rt_client_call "${PROJECT}" "${PROJECT_DIR}" "${_remoteRepos}";
}

function git_init() {

    local _folder="${1}";
    local _remoteRepos="${2}";
    local rescode;
    
    if isDebugEnabled; then
        logDebug -n "Initializing a new git repository";
    fi
    pushd "${_folder}" 2>&1 > /dev/null;
    
    git init 2>&1 > /dev/null
    rescode=$?;

    if [ $rescode -eq 0 ]; then

        if isDebugEnabled; then
            logDebugResult SUCCESS "done";
            logDebug -n "Adding remote ${_remoteRepos}";
        fi

        git remote add origin "${_remoteRepos}" 2>&1 > /dev/null
        rescode=$?;

        popd 2>&1 > /dev/null
        if [ $rescode -eq 0 ]; then

            if isDebugEnabled; then
                logDebugResult SUCCESS "done";
            fi
        else
            if isDebugEnabled; then
                logDebugResult FAILURE "failed";
            fi
            exitWithErrorCode CANNOT_ADD_REMOTE_REPOSITORY;
        fi
    else
        if isDebugEnabled; then
            logDebugResult FAILURE "failed";
        fi
        popd 2>&1 > /dev/null
        exitWithErrorCode CANNOT_SETUP_GIT_REPOSITORY;
    fi
}

function git_add() {

    local _folder="${1}";

    pushd "${_folder}" 2>&1 > /dev/null
    
    if isDebugEnabled; then
        logDebug -n "Adding default file ${DEFAULT_FILE}";
    fi

    echo "# RT repository for ${_remoteRepos}" > "${DEFAULT_FILE}";
    git add "${DEFAULT_FILE}" 2>&1 3>&1 > /dev/null
    rescode=$?;
    if [ $rescode -eq 0 ]; then

        if isDebugEnabled; then
            logDebugResult SUCCESS "done";
        else
            logInfoResult SUCCESS "done";
        fi
        popd 2>&1 > /dev/null
    else
        if isDebugEnabled; then
            logDebugResult FAILURE "failed";
        else
            logInfoResult FAILURE "failed";
        fi
        popd 2>&1 > /dev/null
        exitWithErrorCode CANNOT_ADD_FILES;
    fi
}

function git_commit() {
    local _folder="${1}";
    local rescode;

    pushd "${_folder}" 2>&1 > /dev/null

    if isDebugEnabled; then
        logDebug -n "Committing changes";
    fi

    git commit -m"${COMMIT_MESSAGE}" > /dev/null 2>&1 3>&1
    rescode=$?;
    if [ $rescode -eq 0 ]; then

        if isDebugEnabled; then
            logDebugResult SUCCESS "done";
        else
            logInfoResult SUCCESS "done";
        fi
        popd 2>&1 > /dev/null
    else
        if isDebugEnabled; then
            logDebugResult FAILURE "failed";
        else
            logInfoResult FAILURE "failed";
        fi
        popd 2>&1 > /dev/null
        exitWithErrorCode CANNOT_COMMIT_CHANGES;
    fi  
}

function git_push() {
    local _folder="${1}";
    local rescode;

    pushd "${_folder}" 2>&1 > /dev/null
    
    logInfo -n "Pushing changes";

    git push origin master > /dev/null 2>&1
    rescode=$?;

    if [ $rescode -eq 0 ]; then
        logInfoResult SUCCESS "done";
        popd 2>&1 > /dev/null
    else
        logInfoResult FAILURE "failed";
        popd 2>&1 > /dev/null
        exitWithErrorCode CANNOT_PUSH_CHANGES;
    fi  
}

function add_bashrc_alias() {
    local _project="${1}";
    local _projectDir="${2}";
    local _bashrcAliasFile="${3}";
    local rescode;
    
    logInfo -n "Adding a Bash alias to ${_bashrcAliasFile}";
    echo "alias rt-${_project}=\"git --git-dir \\\"${RT_GIT_DIR}/${_project}\\\" --work-tree \\\"${_projectDir}\\\"\";" >> ${_bashrcAliasFile} 2> /dev/null;
    rescode=$?;

    if [ $rescode -eq 0 ]; then
        logInfoResult SUCCESS "done";
    else
        logInfoResult FAILURE "failed";
        exitWithErrorCode CANNOT_ADD_BASHRC_ALIAS_TO_FILE;
    fi  
}

function add_rt_project() {
    local _project="${1}";
    local _rtProjectFile="${2}";
    local rescode;
    
    logInfo -n "Adding ${_project} to ${_rtProjectFile}";
    echo "${_project}" >> "${_rtProjectFile}" 2> /dev/null;
    rescode=$?;

    if [ $rescode -eq 0 ]; then
        logInfoResult SUCCESS "done";
    else
        logInfoResult FAILURE "failed";
        exitWithErrorCode CANNOT_ADD_RT_PROJECT_TO_FILE;
    fi  
}

function show_rt_client_call() {
    local _project="${1}";
    local _projectDir="${2}";
    local _remoteRepos="${3}";
    
    logInfo "The setup is almost done";
    logInfo -n "Within the ${_projectDir} folder, please run";
    logInfoResult SUCCESS "rt-client.sh init ${_remoteRepos}";
    logInfo "RT's git repository can be managed with rt-${_project} alias instead of git command";
    logInfo "You can now use it to add .gitignore, LICENSE and README.md files";
}
