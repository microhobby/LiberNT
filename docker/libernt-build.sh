#!/bin/sh
set -eu

case "${1:-}" in
	""|-*|menuconfig|Menuconfig|makefiles|Makefiles)
		;;
	*)
		exec "$@"
		;;
esac

SOURCE_DIR=${LIBERNT_SOURCE_DIR:-/libernt}
[ -x "$SOURCE_DIR/configure.sh" ] || {
	echo "libernt-build: no LiberNT source tree at $SOURCE_DIR" >&2
	exit 1
}
cd "$SOURCE_DIR"

./configure.sh "$@"

BUILD_DIR=$(ls -1td output-*-docker/CMakeCache.txt 2>/dev/null | head -n 1)
[ -n "$BUILD_DIR" ] || {
	echo "libernt-build: configure.sh did not produce an output-*-docker tree" >&2
	exit 1
}
BUILD_DIR=$(dirname "$BUILD_DIR")

exec cmake --build "$BUILD_DIR" --parallel "${LIBERNT_JOBS:-$(nproc)}" \
	--target ${LIBERNT_TARGET:-liberntimg}
