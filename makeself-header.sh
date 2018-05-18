cat << EOF  > "$archname"
#!/bin/sh
# This script was generated using Makeself $MS_VERSION

MD5="$MD5sum"
TMPROOT="/tmp"

script="$SCRIPT"
scriptargs="$SCRIPTARGS"
targetdir="$archdirname"
filesizes="$filesizes"
srcchksum="$srcchksum"
libchksum="$libchksum"

unset CDPATH

MS_Progress()
{
    while read a; do
	echo .
    done
}

MS_dd()
{
    dd if="\$1" bs=\$2 skip=1 2> /dev/null
}

UnTAR()
{
    tar \$1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 \$$; }
}

finish=true

initargs="\$@"

while true
do
    case "\$1" in
    -*)
	echo Unrecognized flag : "\$1" >&2
	exit 1
	;;
    *)
	break ;;
    esac
done

if test "\$targetdir" = "."; then
    tmpdir="."
else
    tmpdir="\$TMPROOT/selfgz\$\$\$RANDOM"
    dashp=""

    mkdir \$dashp \$tmpdir || {
	echo 'Cannot create target directory' \$tmpdir >&2
	echo 'You should try option --target OtherDirectory' >&2
	eval \$finish
	exit 1
    }
fi

location="\`pwd\`"
offset=\`head -n $SKIP "\$0" | wc -c | tr -d " "\`

echo "Uncompressing"
res=3
trap 'echo Signal caught, cleaning up >&2; cd \$TMPROOT; /bin/rm -rf \$tmpdir; eval \$finish; exit 15' 1 2 3 15

for s in \$filesizes
do

    if MS_dd "\$0" \$offset \$s | ${ENCRYPTTOOL} -d | eval gunzip | ( cd "\$tmpdir"; UnTAR x ) | MS_Progress; then
	:
    else
	echo
	echo "Unable to decompress \$0" >&2
	eval \$finish; exit 1
    fi
    offset=\`expr \$offset + \$s\`
done
echo

cd "\$tmpdir"
res=0
if test x"\$script" != x; then
	eval \$script \$scriptargs \$*; res=\$?
fi

eval \$finish; exit \$res
EOF
