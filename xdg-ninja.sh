#!/usr/bin/env sh

has_command() {
    command -v "$1" >/dev/null 2>/dev/null
    return $?
}

DECODER="cat"
if has_command glow; then
    DECODER="glow -"
else
    if has_command bat; then
        DECODER="bat -pp --decorations=always --color=always --language markdown"
        printf "Markdown rendering will be done by bat. (Glow is recommended)\n"
    elif has_command pygmentize; then
        DECODER="pygmentize -l markdown"
        printf "Markdown rendering will be done by pygmentize. (Glow is recommended)\n"
        USE_PYGMENTIZE=true
    elif has_command highlight; then
        DECODER="highlight --out-format ansi --syntax markdown"
        printf "Markdown rendering will be done by highlight. (Glow is recommended)\n"
    else
        printf "Markdown rendering not available. (Glow is recommended)\n"
        printf "Output will be raw markdown and might look weird.\n"
    fi
    printf "Install glow for easier reading & copy-paste.\n"
fi

unalias -a

#Set ansi color code variables
set_colors() {
    case $COLOR in
        never)
            DECODER="cat"
            return
        ;;
        auto)
            if [ ! -t 1 ] || [ $NO_COLOR ];then # Check if used in a pipe or if the NO_COLOR env variable is set.
                DECODER="cat" 
                return
            fi
        ;;
    esac
    ANSI_BEGIN="\033["
    ANSI_END="m"

    ANSI_CLEAR=";0"
    ANSI_BOLD=";1"
    ANSI_ITALLIC=";3"

    ANSI_RED=";31"
    ANSI_GREEN=";32"
    ANSI_YELLOW=";33"
    ANSI_CYAN=";36"
    ANSI_WHITE=";37"

    ANSI_BACKGROUND_PURPLE=";45"
}

help() {
    set_colors
    HELPSTRING="""\


        ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_WHITE}${ANSI_BACKGROUND_PURPLE}${ANSI_END}xdg-ninja${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}

        ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}Check your \$HOME for unwanted files.${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}

        ────────────────────────────────────

        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}--help${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}              ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}This help menu${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}
        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}-h${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}

        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}--no-skip-ok${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}        ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}Display messages for all files checked (verbose)${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}
        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}-v${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}

        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}--skip-ok${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}           ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}Don't display anything for files that do not exist (default)${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}
        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}--color=WHEN${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}        ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}Color the output always, never, or auto (default)${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}
        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}--decoder=DECODER${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}   ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}Manually set the decoder used for markdown.${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}
        ${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}--json${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}              ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}Output json${ANSI_BEGIN}${ANSI_CLEAR}${ANSI_END}

"""
printf "%b" "$HELPSTRING"
exit
}

SKIP_OK=true
COLOR=auto
JSON=false
for i in "$@"; do
    case $i in
        --color=*)
            COLOR="${i#*=}"
            ;;
        --help|-h)
            help
            ;;
        --skip-ok)
            SKIP_OK=true
            ;;
        --no-skip-ok|-v)
            SKIP_OK=false
            ;;
        --decoder=*)
            DECODER="${i#*=}"
            ;;
        --json)
            JSON=true
            ;;
    esac
done

set_colors

if [ -z "${XDG_DATA_HOME}" ]; then
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n" "The \$XDG_DATA_HOME environment variable is not set, make sure to add it to your shell's configuration before setting any of the other environment variables!"
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}    ⤷ ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}The recommended value is: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}\$HOME/.local/share${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
fi
if [ -z "${XDG_CONFIG_HOME}" ]; then
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n" "The \$XDG_CONFIG_HOME environment variable is not set, make sure to add it to your shell's configuration before setting any of the other environment variables!"
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}    ⤷ ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}The recommended value is: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}\$HOME/.config${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
fi
if [ -z "${XDG_STATE_HOME}" ]; then
    printf '${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n' "The \$XDG_STATE_HOME environment variable is not set, make sure to add it to your shell's configuration before setting any of the other environment variables!"
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}    ⤷ ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}The recommended value is: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}\$HOME/.local/state${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
fi
if [ -z "${XDG_CACHE_HOME}" ]; then
    printf '${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n' "The \$XDG_CACHE_HOME environment variable is not set, make sure to add it to your shell's configuration before setting any of the other environment variables!"
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}    ⤷ ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}The recommended value is: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}\$HOME/.cache${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
fi
if [ -z "${XDG_RUNTIME_DIR}" ]; then
    printf '${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n' "The \$XDG_RUNTIME_DIR environment variable is not set, make sure to add it to your shell's configuration before setting any of the other environment variables!"
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}    ⤷ ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_END}The recommended value is: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}/run/user/\$UID${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
fi

if ! command -v jq >/dev/null 2>/dev/null; then
    printf "jq is needed to run this script, but it wasn't found. Please install it to be able to use this script.\n"
    exit
fi

printf "\n"

# Function to expand environment variables in string
# https://stackoverflow.com/a/20316582/11110290
apply_shell_expansion() {
    data="$1"
    delimiter="__apply_shell_expansion_delimiter__"
    command=$(printf "cat <<%s\n%s\n%s" "$delimiter" "$data" "$delimiter")
    eval "$command"
}

# Returns 0 if the path doesn't lead anywhere
# Returns 1 if the path leads to something
check_if_file_exists() {
    FILE_PATH=$(apply_shell_expansion "$1")
    if [ -e "$FILE_PATH" ]; then
        return 1
    else
        return 0
    fi
}

decode_string() {
    printf "%s" "$1" | sed -e 's/\\n/\
/g' -e 's/\\\"/\"/g' -e '$ s/\n*$/\
\
/' # Replace \n with literal newline and \" with ", normalize number of trailing newlines to 2
}

# Function to handle the formatting of output
log() {
    MODE="$1"
    NAME="$2"
    FILENAME="$3"
    HELP="$4"

    case "$MODE" in

    ERR)
        printf "[${ANSI_BEGIN}${ANSI_BOLD}${ANSI_RED}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}]: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n" "$NAME" "$FILENAME"
        ;;

    WARN)
        printf "[${ANSI_BEGIN}${ANSI_BOLD}${ANSI_YELLOW}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}]: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n" "$NAME" "$FILENAME"
        ;;

    INFO)
        printf "[${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}]: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n" "$NAME" "$FILENAME"
        ;;

    SUCS)
        [ "$SKIP_OK" = false ] &&
            printf "[${ANSI_BEGIN}${ANSI_BOLD}${ANSI_GREEN}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}]: ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}%s${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n" "$NAME" "$FILENAME"
        ;;

    HELP)
        decode_string "$HELP" | $DECODER
        ;;

    esac
}

# Checks that the given file does not exist, otherwise outputs help
check_file() {
    NAME="$1"
    FILENAME="$2"
    MOVABLE="$3"
    HELP="$4"
	JSON_FILE="$5"

    check_if_file_exists "$FILENAME"

    case $? in

    0)
        [ "$SKIP_OK" = false ] && [ "$JSON" = true ] && cat "$JSON_FILE" && return
        log SUCS "$NAME" "$FILENAME" "$HELP"
        ;;

    1)
        [ "$JSON" = true ] && cat "$JSON_FILE" && return
        if [ "$MOVABLE" = true ]; then
            log ERR "$NAME" "$FILENAME" "$HELP"
        else
            log WARN "$NAME" "$FILENAME" "$HELP"
        fi
        if [ "$HELP" ]; then
            log HELP "$NAME" "$FILENAME" "$HELP"
        else
            log HELP "$NAME" "$FILENAME" "_No help available._"
        fi
        ;;

    esac
}

# Reads files from programs/, calls check_file on each file specified for each program
do_check_programs() {
    while IFS="
" read -r name; read -r filename; read -r movable; read -r help; read -r json_file;  do
        check_file "$name" "$filename" "$movable" "$help" "$json_file"
    done <<EOF
$(jq 'inputs as $input | $input.files[] as $file | $input.name, $file.path, $file.movable, $file.help, input_filename' "$(dirname "$0")"/programs/* | sed -e 's/^"//' -e 's/"$//')
EOF
# sed is to trim quotes
}

check_programs() {
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}Starting to check your ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}\$HOME.${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
    printf "\n"
    do_check_programs
    printf "${ANSI_BEGIN}${ANSI_BOLD}${ANSI_ITALLIC}${ANSI_END}Done checking your ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}\$HOME.${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
    printf "\n"
    printf "${ANSI_BEGIN}${ANSI_ITALLIC}${ANSI_END}If you have files in your ${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CYAN}${ANSI_END}\$HOME${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END} that shouldn't be there, but weren't recognised by xdg-ninja, please consider creating a configuration file for it and opening a pull request on github.${ANSI_BEGIN}${ANSI_BOLD}${ANSI_CLEAR}${ANSI_END}\n"
    printf "\n"
}

check_programs
