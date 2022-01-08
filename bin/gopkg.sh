#!/usr/bin/env bash

#
# VARS
#



#
# FUNCTIONS
#

function usage(){
    printf "Usage

    [overview]
    Use the \$GOPATH environment variable to manage the go packages

    [command]
    gopkg [options]

    [options]
    -l | --list       List the installed packages
    -i | --install    Install the given package in \$GOPATH
    -d | --delete     Uninstall the given package in \$GOPATH
    -u | --update     Update the given package in \$GOPATH
"
}

function list() {
    except=( "cache" )
    pkgs_root="${GOPATH}/pkg/mod"
    pkgs=$(find "${GOPATH}/pkg/mod" -type f -name "go.mod")
    for pkg in ${pkgs[*]}; do
        mod_name="${pkg#"${pkgs_root}/"}"
        dirname "${mod_name}"
    done
}

function install() {
    go get "$1"
}


function update() {
    go get -u "$1"
}

function delete() {
    base_name=$(basename "$1")
    source_name=$(basename "$(dirname "$1")")

    # delete pkg
    pkgs=$(find "${GOPATH}/pkg" -type d -name "*${base_name}*")
    for pkg in ${pkgs[*]}; do
        if [ "$(basename "$(dirname "${pkg}")")" == "${source_name}" ]; then
            sudo rm -rf "${pkg}"
        fi
    done

    # delete src
    srcs=$(find "${GOPATH}/src" -type d -name "*${base_name}*")
    for src in ${srcs[*]}; do
        if [[ "$(basename "$(dirname "${src}")")" == *"${source_name}"* ]]; then
            sudo rm -rf "${pkg}"
        fi
    done
}

#
# PARSING
#

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -h | --help)
        usage
        exit 0
        ;;
    -l | --list)
        list
        shift 1
        ;;
    -i | --install)
        update "$2"
        shift 2
        ;;
    -d | --delete)
        delete "$2"
        shift 2
        ;;
    -u | --update)
        update "$2"
        shift 2
        ;;
    *) # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        echo "! Unknown parameter"
        usage
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

#
# MAIN
#