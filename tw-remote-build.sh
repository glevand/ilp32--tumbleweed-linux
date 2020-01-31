#!/bin/bash

on_exit() {
	local result=${1}

	echo "${name}: Done: ${result}" >&2
}

#===============================================================================
export PS4='\[\033[0;33m\]+${BASH_SOURCE##*/}:${LINENO}: \[\033[0;37m\]'
set -x

name="${0##*/}"

trap "on_exit 'failed.'" EXIT
set -e

sudo="sudo -S"

k_ver="${k_ver:-5.4.14-231.1}"

k_base="${k_ver%.*}"
k_src="${HOME}/projects/ilp32/tw-64k-kernel/tw-64k-kernel-src"
build_base="${HOME}/projects/ilp32/tw-64k-kernel/build-${k_ver}"

op="${1:-build}"

cd ${build_base}

echo "${name}: INFO: op = '${op}'." >&2

while true; do
	case ${op} in
	build)
		"${HOME}/projects/tci/git/tci/scripts/build-linux-kernel.sh" --build-dir="${build_base}/build" --install-dir="${build_base}/install" native "${k_src}" ${op}
		op="install"
		;;
	rebuild)
		"${HOME}/projects/tci/git/tci/scripts/build-linux-kernel.sh" --build-dir="${build_base}/build" --install-dir="${build_base}/install" native "${k_src}" oldconfig
		"${HOME}/projects/tci/git/tci/scripts/build-linux-kernel.sh" --build-dir="${build_base}/build" --install-dir="${build_base}/install" native "${k_src}" rebuild
		op="install"
		;;
	install)
		#${sudo} cp -av --link /boot "/boot--$(date +%m.%d-%H.%M)"
		(cd ${build_base}/build && ${sudo} make modules_install install)
		break
		;;
	*)
		echo "${name}: ERROR: Unknown op '${op}'." >&2
		exit 1
		;;
	esac
done

trap "on_exit 'Success.'" EXIT
exit 0
