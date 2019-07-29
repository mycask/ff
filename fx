#!/bin/sh

# fx - Execute command with partial paths resolved to absolute paths.
#
#Copyright (c) 2017 Susam Pal
# All rights reserved.


# Starting point of this script.
#
# Arguments:
#   arg...: All arguments this script is invoked with.
main()
{
    . fcom

    parse_arguments "$@"

    # Do not resolve command and sub-commands.
    case $1 in
        git | go)
            cmd="\"$1\" \"$2\""
            shift 2
            ;;
        *)
            cmd="\"$1\""
            shift
            ;;
    esac

    while [ $# -gt 0 ]
    do
        arg=$1

        # Do not resolve options.
        if printf "%s" "$arg" |
           grep -q -E "^(=.*|-.*|\+.*)$"
        then
            # An argument beginning with '=' should be not be resolved. The
            # '=' should be removed though before executing.
            cmd="$cmd ${arg#=}"
        elif path=$(ff "${arg#%}")
        then
            cmd="$cmd \"$path\""
        else
            exit 1
        fi

        shift
        unset arg
    done

    printf "%s\n" "$cmd"
    eval "$cmd"
}


# Parse command line arguments passed to this script.
#
# Arguments:
#   arg...: All arguments this script is invoked with.
#
# Errors:
#   Exit with an error message when invalid arguments are specified.
parse_arguments()
{
    while [ "$#" -gt 0 ]
    do
        case $1 in
            -h | --help)
                show_help
                exit
                ;;
            -v | --version)
                show_version
                exit
                ;;
            -?*)
                quit Unknown option \""$1"\".
                ;;
            *)
                break 
                ;;
        esac
    done

    [ $# -lt 2 ] && quit Command \""$1"\" must be followed by one or \
                         more patterns.
}


# Show help.
show_help()
{
    printf "%s\n" \
"Usage: $NAME COMMAND [[=]ARG]... [[%]PATH]...

Execute COMMAND with one or more PATH arguments resolved to absolute
paths. An absolute path or partial path to a file or a directory must be
specified as PATH.

Any argument that begins with a minus or plus is considered to be an option
and not resolved to an absolute path. Additionally, any argument that begins
with '=' are not resolved; the '=' is removed from the argument before using
it in the command.

All other arguments are resolved to an absolute path. An argument that
begins with '%' is always resolved to an absolute path; the '%' is
removed from the argument before using it in the command. It is an error
if the resolution fails.

Options:
  -h, --help     Show this help and exit.
  -v, --version  Show version and exit.

Report bugs to $AUTHOR."
}


main "$@"
