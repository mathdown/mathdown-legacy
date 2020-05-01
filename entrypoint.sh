#!/bin/sh -eu

root="${root-.}"

quote() {
	printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
}

while [ -n "${1+x}" ]; do
	case "$1" in
		-h|-help)
			echo "entrypoint.sh: system environment setup script"
			echo
			echo "Usage: entrypoint.sh [flags] [--] [args]"
			echo
			echo "Flags:"
			echo "	 -h: print help message"
			echo "	 -v: enable verbose mode"
			echo "	 -t bool: include table of contents"
			echo "	 -i path: path to input file"
			echo "	 -o path: path to output file"
			echo "   -p title: page title"
			echo
			exit 0
			;;
		-v|-verbose)
			shift
			set -x
			;;
		-t|-toc)
			shift
			if [ -z "${1+x}" ]; then
				echo "Expected flag argument" >&2
			fi
			if [ "$1" = true ]; then
				toc=--table-of-contents
			else
				toc=
			fi
			shift
			;;
		-i|-input)
			shift
			if [ -z "${1+x}" ]; then
				echo "Expected input file path" >&2
			fi
			input="$1"
			shift
			;;
		-o|-output)
			shift
			if [ -z "${1+x}" ]; then
				echo "Expected output file path" >&2
			fi
			output="$1"
			shift
			;;
		-p|-pagetitle)
			shift
			if [ -z "${1+x}" ]; then
				echo "Expected page title" >&2
			fi
			pagetitle=--variable=pagetitle:"$1"
			shift
			;;
		--)
			shift
			break;
			;;
		-*)
			flag=`quote "$1"`
			echo "Unknown option $flag" >&2
			exit 1
			;;
		*)
			shift
			break
			;;
	esac
done

if [ -z "${input+x}" -o -z "${output+x}" ]; then
	if [ -z "${input+x}" ]; then
		echo "Missing input file path" >&2
	fi
	if [ -z "${output+x}" ]; then
		echo "Missing output file path" >&2
	fi
	exit 1
fi

if [ -n "${toc-}" ]; then
	set -- "${toc}" "$@"
fi
if [ -n "${pagetitle-}" ]; then
	set -- "${pagetitle}" "$@"
fi
pandoc "$@" --mathjax --template="$root"/template.htm --output="$output" -- "$input"
node "$root"/build.js "$output"
