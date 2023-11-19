#!/usr/bin/env bash

################################################################################
#
# General purpose Bash Hierarchy Logging utility script.
#
# WARNING: This is not an executable script. This script is meant to be used as
# a utility by sourcing this script.
#
########################################################### Global Variables ###
#
# LOG_DEBUG_LEVEL       = Debug level to trigger log level. Default = 7 (CRIT)
#                         DEBUG > INFO > NOTICE > WARN > ERROR > CRIT
#                         ALERT, and EMERG are unused and unhandled.
# LOG_POP_CALLSTACK     = Pop from callstack in dump_stack(). Pop 2 by default
#                         to omit dump_stack() and log()
# LOG_TIMESTAMP_FORMAT  = Date and time format for log timestamp.
# LOG_FILELOG_ENABLE    = Enable file logging.
# LOG_FILELOG_DIR       = Directory to store file log.
# LOG_FILELOG_NAME      = File log filename (exclude file extension)
# LOG_SYSLOG_ENABLE     = Enable system logging (uses built-in `logger`)
# LOG_SYSLOG_TAG        = `logger` tag (defaults to basename)
# LOG_SYSLOG_FACILITY   = `logger` facility (defaults to local0)
#
###################################################################### Usage ###
#
# log 'warn' 'This is a warning message'
#
################################################################################
# Author:   Mark Lucernas <https://github.com/marklcrns>
# Date:     2021-06-03
#
# Credits:  Mike Peachey <https://github.com/Zordrak/bashlog/blob/master/log.sh>
################################################################################

if [ "${0##*/}" == "${BASH_SOURCE[0]##*/}" ]; then
	echo "WARNING: $(realpath -s $0) is not meant to be executed directly!" >&2
	echo "Use this script only by sourcing it." >&2
	exit 1
fi

# Header guard
[[ -z "${COMMON_LOG_SH_INCLUDED+x}" ]] &&
	readonly COMMON_LOG_SH_INCLUDED=1 ||
	return 0

source "${BASH_SOURCE%/*}/colors.sh"

function _log_exception() {
	(
		LOG_FILELOG=false
		LOG_SYSLOG=false

		log 'error' "Log Exception: ${@}"
	)
}

# Credits:
# https://unix.stackexchange.com/q/80476
# https://stackoverflow.com/a/22617858
function dump_stack() {
	local __pop="${1:-${LOG_POP_CALLSTACK:-2}}" # pop 2 by default to omit dump_stack() and log()

	local __indent="${__indent:-}  "
	printf "${__indent}Function call stack ( command.function() ) ...\n" >&2
	__indent="${__indent}  "

	local __i="${#FUNCNAME[@]}"
	((--__i))

	local stack=
	while (($__i >= __pop)); do
		stack+="${__indent}${BASH_SOURCE[${__i}]}.${FUNCNAME[${__i}]}():${BASH_LINENO[${__i} - 1]}\n"
		__indent="${__indent}|  "
		((--__i))
	done
	printf "${stack}" >&2
}

function log() {
	local __timestamp_format="${LOG_TIMESTAMP_FORMAT:-+%Y-%m-%dT%H:%M:%S}"
	local __date="$(date ${__timestamp_format})"

	local __filelog="${LOG_FILELOG:-false}"
	local __filelog_dir="${LOG_FILELOG_DIR:-/tmp}"
	local __filelog_name="${LOG_FILELOG_NAME:-$(realpath -s "${0}" | sed "s,/,%,g")}"
	local __filelog_path="${__filelog_dir}/${__filelog_name}.log"

	local __syslog="${LOG_SYSLOG:-false}"
	local __syslog_tag="${LOG_SYSLOG_TAG:-$(basename -- "${0}")}"
	local __syslog_facility="${LOG_SYSLOG_FACILITY:-local0}"

	local __pid="${$}"
	local __level="$(echo "${1}" | awk '{print tolower($0)}')"
	local __level_upper="$(echo "${__level}" | awk '{print toupper($0)}')"

	local __message="${2:-}"
	local __exit="${3:-0}"

	local -A __severity
	__severity['DEBUG']=7
	__severity['INFO']=6
	__severity['NOTICE']=5
	__severity['WARN']=4
	__severity['ERROR']=3 # Default
	__severity['CRIT']=2
	__severity['ALERT']=1 # Unused
	__severity['EMERG']=0 # Unused
	readonly __severity

	local __debug_level="${LOG_DEBUG_LEVEL:-3}"
	local __severity_level="${__severity[${__level_upper}]:-2}"

	# Log all levels
	if [[ "${__debug_level}" -ge 0 ]] && [[ "${__severity_level}" -le 7 ]]; then

		if ${__syslog}; then
			local syslog_message="${__level_upper}: ${__message}"
			logger \
				--id="${__pid}" \
				-t "${__syslog_tag}" \
				-p "${__syslog_facility}.${__severity_level}" \
				"${syslog_message}" ||
				_log_exception "logger --id=\"${__pid}\" -t \"${__syslog_tag}\" -p
              \"${__syslog_facility}.${__level}\" \"${syslog_message}\""
		fi

		if ${__filelog}; then
			local file_message="${__date} [${__level_upper}] ${__message}"
			echo -e "${file_message}" >>"${__filelog_path}" ||
				_log_exception "echo -e \"${file_message}\" >> \"${__filelog_path}\""
		fi

	fi

	if [[ "${__severity_level}" -gt "${__debug_level}" ]]; then
		return
	fi

	local -A __colors
	__colors['DEBUG']="${COLOR_PURPLE}"
	__colors['INFO']="${COLOR_HI_BLACK}"
	__colors['NOTICE']="${COLOR_BLUE}"
	__colors['WARN']="${COLOR_YELLOW}"
	__colors['ERROR']="${COLOR_RED}"
	__colors['CRIT']="${COLOR_BO_RED}"
	__colors['ALERT']="${COLOR_BO_RED}"
	__colors['EMERG']="${COLOR_BO_RED}"
	__colors['DEFAULT']="${COLOR_NC}"
	readonly __colors

	# Stdout (Pretty)
	local __normal_color="${__colors['DEFAULT']}"
	local __color="${__colors[${__level_upper}]:-\033[0m}" # Defaults to normal

	local out="${__color}[${__level_upper}] ${__date} ${__message}${__normal_color}"

	case "${__level}" in
	'info' | 'notice' | 'warn' | 'debug')
		echo -e "${out}"
		;;
	'error' | 'crit')
		echo -e "${out}" >&2
		if [[ "${__debug_level}" -ge 0 ]] && [[ "${__exit}" -gt 0 ]]; then
			if [[ "${LOG_DEBUG_LEVEL:-}" -ge 7 ]]; then
				dump_stack
				echo -e "${__color}$(realpath -- ${0}): Exited with ${__exit}${__normal_color}"
			fi
			exit ${__exit}
		fi
		;;
	*)
		log 'error' "Undefined log level '${__level}' trying to log: '${@}'"
		;;
	esac
}

############################################################ Test DEBUG trap ###

# Test

# declare prev_cmd="null"
# declare this_cmd="null"
# trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND' DEBUG \
#   && log 'debug' 'DEBUG trap set' \
#   || log 'error' 'DEBUG trap failed to set'

# This is an option if you want to log every single command executed,
# but it will significantly impact script performance and unit tests will fail

# declare prev_cmd="null"
# declare this_cmd="null"
# trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND; log debug $this_cmd' DEBUG \
#  && log 'debug' 'DEBUG trap set' \
#  || log 'error' 'DEBUG trap failed to set'
