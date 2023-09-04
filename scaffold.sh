#!/usr/bin/env bash
#
# Adapted from https://www.shellscript.sh/examples/getopt/
#
set -euo pipefail

M4BIN=$(which m4 2>/dev/null)
B64BIN=$(which base64 2>/dev/null)
SEDBIN=$(which sed 2>/dev/null)
NASM_FLAGS=" -f elf32 -g "
LD_FLAGS=" -m  elf_i386 "

if [[ -z "${M4BIN}" ]]; then
	echo "m4 macro processor not found"
	exit 2
fi

if [[ -z "${SEDBIN}" ]]; then
	echo "sed not found"
	exit 2
fi

if [[ -z "${B64BIN}" ]]; then
	echo "base64 not found"
	exit 2
fi

BASE=
SCRIPT_NAME=
PROJECT_DIR=
TITLE=
AUTHOR='Giuseppe Manzo'
DATE=$(date +%Y-%m-%y)

# Boolean: remove project directory
CLEANUP=

usage(){
>&2 cat << EOF
Usage: $0
   [-b | --base] Script Title 

   [-a | --asmfile]  Dump asm template
   [-m | --makefile] Dump Makefile template
   [-c | --cleanup]  Remove project directory if exists before scaffold
EOF
exit 1
}


output_tag() {
	TAG=$1
	case ${TAG} in
	ASM)
		${SEDBIN} -n "/^ASM_BEGIN/,/^ASM_END/p" $0 | ${SEDBIN} -e '1d' -e '$d' | ${B64BIN} -d
		;;
	MAKE)
		${SEDBIN} -n "/^MAKEFILE_BEGIN/,/^MAKEFILE_END/p" $0 | ${SEDBIN} -e '1d' -e '$d' | ${B64BIN} -d
		;;
	*)
		echo "Unknown tag: ${TAG}" >&2
		;;
	esac

}

output_template() {
	TAG=$1
	TARGET=

	case ${TAG} in
		ASM)
			TARGET=${SCRIPT_NAME}
		;;
		MAKE)
			TARGET=Makefile
		;;
		*)
			echo "Unknown tag name ${TAG}" >&2
			exit
	esac


	${M4BIN} \
		-D title="${TITLE}" \
		-D author="${AUTHOR}" \
		-D date="${DATE}" \
		-D nasm_flags="${NASM_FLAGS}" \
		-D base="${BASE}" \
		-D script_name="${SCRIPT_NAME}" \
		-D ld_flags="${LD_FLAGS}" \
		- > ${PROJECT_DIR}/${TARGET}
}

args=$(getopt -a -o b:amc --long base:,asmfile,makefile,cleanup -- "$@")
if [[ $? -gt 0 ]]; then
  usage
fi

eval set -- ${args}
while :
do
  case $1 in
    -b | --base)
	BASE=$2;
	SCRIPT_NAME=${BASE}.asm
	TITLE=${BASE^^${BASE:0:1}}
	PROJECT_DIR=${BASE}
	shift 2
	;;
    -a | --asmfile)
	output_tag ASM
	exit
	;;
    -m | --makefile)
	output_tag MAKE
	exit
	;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    *) >&2 echo Unsupported option: $1
       usage ;;
  esac
done

if [[ -z ${BASE} ]]; then
	echo "Option --base | -b required"
	usage
fi

echo "BASE: ${BASE}"
echo "SCRIPT_NAME: ${SCRIPT_NAME}"
echo "TITLE: ${TITLE}"
echo "AUTHOR: ${AUTHOR}"
echo "LD_FLAGS: ${LD_FLAGS}"
echo "NASM_FLAGS: ${NASM_FLAGS}"


if [[ -d ${PROJECT_DIR} ]];then
	echo "A directory with name ${PROJECT_DIR} already exists. Giving up..." >&2
	exit
fi

mkdir ${PROJECT_DIR}

output_tag MAKE | output_template MAKE
output_tag ASM | output_template ASM

exit

MAKEFILE_BEGIN
CmJhc2U6CWJhc2UubwoJbGQgbGRfZmxhZ3MgLW8gYmFzZSBiYXNlLm8KCmJhc2UubzoJYmFzZS5h
c20KCW5hc20gbmFzbV9mbGFncyAtbyBiYXNlLm8gYmFzZS5hc20KCmNsZWFuOgoJcm0gYmFzZSBi
YXNlLm8KCgo=
MAKEFILE_END

ASM_BEGIN
CjsJUHJvZ3JhbToJdGl0bGUKOwlBdXRob3I6CQlhdXRob3IKOwlVcGRhdGVkOglkYXRlCjsKOwlj
b21waWxlIHdpdGg6CjsJCW5hc20gbmFzbV9mbGFncyAtbyBiYXNlLm8gc2NyaXB0X25hbWUKOwkJ
bGQgbGRfZmxhZ3MgLW8gYmFzZSBiYXNlLm8KOwoKc2VjdGlvbiAuZGF0YQoKc2VjdGlvbiAuYnNz
CgpzZWN0aW9uIC50ZXh0Cgpfc3RhcnQ6CgoJbm9wCgpFeGl0Ogltb3YgZWF4LCAxCQk7IHN5c19l
eGl0CgkJbW92IGVieCwgMAkJOyBleGl0IHdpdGggdmFsdWUgMAoJCWludCA4MGgJCQk7IGtlcm5l
bAoKCW5vcAoK
ASM_END

