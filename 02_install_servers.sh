#! /usr/bin/env sh
WINDVPN="$HOME"'/windvpn/'  # must have trailing slash
PROCDIR='udp_procd' # match what's in autoconfigurator
INSTDIR='/etc/openvpn/wyatt/autoinst/'
echo 'first, erasing old files in /etc/openvpn/wyatt/autoinst'
# too many files to just use rm *.ovpn (argument list too long)
set -x
sudo find /etc/openvpn/wyatt/autoinst/ -type f -name '*.ovpn' -exec rm {} \;
set +x
cd "$WINDVPN"
mkdir -p "$PROCDIR"
mkdir -p processed
# this script can be run standalone, outside of my installer stuff, which may
# make it handy for other peoples' use.
./install_autoconfigurator.sh 

unset FILENAME 2>/dev/null
unset file 2>/dev/null
for file in "$WINDVPN""$PROCDIR"'/'*; do
  FILENAME="$(basename "$file")"
  # change from local auth.txt that was added by above script to the one at
  # /etc/openvpn/wyatt/auth.txt
  sed 's!^auth-user-pass.*$!auth-user-pass /etc/openvpn/wyatt/auth.txt!' < "$file" > './processed/'"$FILENAME"
  sudo cp './processed/'"$FILENAME" "$INSTDIR"
  sudo chown root:root "$INSTDIR""$FILENAME"
  rm './processed/'"$FILENAME"
done

rmdir processed
