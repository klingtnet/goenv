# -*- mode: sh; -*-
# Virtual environments for go. Inspired from pythons vex https://pypi.python.org/pypi/vex
#
# Andreas Linz
# www.klingt.net

goenv_check() {
# http://stackoverflow.com/a/3243034
    if [ -z ${GOENVS+GOENVS} ]; then
        echo "GOENVS environment variable is not set!"
        eval $1=''
    elif [ ! -d $GOENVS ]; then
        echo "$GOENVS is not a directory!"
        eval $1=''
    fi
}

goenv_help() {
    echo "goenv [option] <name>
    Omitting the option will activate the environment <name>. If the environment does'nt exist, it will be created.

    -l, --list      list goenvs in \"$GOENVS\"
    -c, --create    create goenv in \"$GOENVS\"
    -r, --remove    removes one or more goenvs <name> [<name2> ...]
    -e, --exec      run a command(s) in goenv <name>.
        Example: goenv -e hello \"foo -b -a -r\"
    --remove-all    removes all of your goenvs (use this with care!)
    -h, --help      prints this help text"
}

goenv_start() {
    if [ -z $(goenv --list | grep -- "$1") ]; then
        goenv -c "$1"
    fi
    $SHELL -c "export GOPATH=$GOENVS/$1;\
export GOENV_NAME=$1;\
PATH=$GOENVS/$1/bin:$PATH;\
$SHELL -i"
}

goenv_exec() {
    if [ -z $(goenv --list | grep -- "$1") ]; then
        echo "Missing envrionment: $1"; return
    fi
    $SHELL -c "export GOPATH=$GOENVS/$1;\
export GOENV_NAME=$1;\
PATH=$GOENVS/$1/bin:$PATH;\
${@:2}"
}

goenv_create() {
    if [ -e "$GOENVS/$1" ]; then
        echo "Environment \"$1\" already exists!"; return
    fi
    echo "Creating goenv $1 in $GOENVS/$1 ..."
    mkdir -p "$GOENVS/$1/bin"
}

goenv_list() {
    for D in $(ls -A $GOENVS); do 
        if [ -d "$GOENVS/$D" ]; then 
            echo $D
        fi
    done
}

goenv_remove() {
    for GE in "$@"; do
# paranoid checks ahead
        if [ -d "$GOENVS/$GE" ]; then
            if [ -z "$GOENVS" ] || [ -z "$GE" ]; then
                echo "\"$GOENVS\" or \"$GE\" is empty, canceling ... "
                continue
            fi 
            echo "Removing goenv $GE ..."
            rm -rf "$GOENVS/$GE"
        else
            echo "$GE does not exist!"
        fi
    done
}

# Argument slicing: "${@:start:len}"
goenv() {
# Parameter Expansion: ... Omitting the colon results in a test only for a parameter that is unset. ...
    local goenv_ok='okay'
    goenv_check goenv_ok
    if [ -z "$goenv_ok" ]; then echo "Fix the errors!"; return; fi
    if [ $# -eq 0 ]; then
        goenv_help
    else
        case "$1" in
        "-c" | "--create")
            goenv_create "${@:2}"
            ;;
        "-r" | "--remove")
            goenv_remove "${@:2}"
            ;;
        "--remove-all")
            goenv_remove $(goenv --list | tr '[:blank:]' ' ')
            ;;
        "-l" | "--list")
            goenv_list
            ;;
        "-h" | "--help")
            goenv_help
            ;;
        "-e" | "--exec")
            goenv_exec "${@:2}"
            ;;
        *)
            goenv_start "$@"
            ;;
        esac
    fi
}
