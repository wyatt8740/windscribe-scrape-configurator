#! /bin/sh
# For windscribe.
# Converts the dumb city/nickname format to
# [region][servernumber]-city_nickname format, since that's what most people
# care about (changing countries for evasion of stuff).

# Works nicely alongside the Windscribe OpenVPN config file scraper
# found here: https://github.com/wilmardo/windscribe-ovpn-config-scraper.git

# this script was made to be workable with pretty much any JS interpreter.
# But unfortunately it does need one to parse some JSON.
# If you must use spidermonkey, rhino, node/V8 or whatever, this is where
# you need to change something.
# Default: Duktape (duk).
JS='duk'

get_list() {
  # this gets a JSON string containing all of the extra information I need to
  # rename these files to my liking.
  # 'Pro'/premium servers URL:
  #   https://assets.windscribe.com/serverlist/openvpn/1/1
  # Free servers URL:
  #   https://assets.windscribe.com/serverlist/openvpn/0/1
  # Apparently, some staff posted this link in the windscribe discord at one
  # point.
  # I can't stand discord, though, so I can't verify that (I like IRC).
  curl -s https://assets.windscribe.com/serverlist/openvpn/1/1 | sed 's/^ *//g;s/ *$//g' | tr '\n' '#'|sed 's/\#//g'
}

# everything happens in this dir or subdirectories of it.
WORKDIR="$HOME"'/windvpn'

# Don't do it here. or if you do it here, USE RESTRICTIVE PERMISSIONS.
AUTHFILE="$HOME"'/windvpn/auth.txt'

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# make some directories
mkdir -p udp
mkdir -p tcp
# might replace this directory later
mkdir -p procd

# make sure files exist before trying to move them.
ls scraped | grep -q udp\\.ovpn
if [ "$?" -eq 0 ]; then
  cp scraped/*udp.ovpn udp/
fi
ls scraped | grep -q tcp\\.ovpn
if [ "$?" -eq 0 ]; then
  cp scraped/*tcp.ovpn tcp/
fi

JSON="$(get_list)"
sed 's#REPLACE_WITH_JSON#'"$JSON"'#' template.js > tmp_json.js

# make a function for it so we can do it for both udp and tcp if we want
makefiles() {
  DIR="$1"
  mkdir -p "$WORKDIR"'/'"$DIR"
  cd "$WORKDIR"'/'"$DIR"
  for file in *.ovpn; do
    # For those of you who haven't done a lot with regexes, I'm sorry about
    # this. Really, I am.
    # I had to find a way to deal with the filenames given by the scraper
    # having the spaces stripped out of them. The JSON file we are parsing
    # still has them. This ends up working based on the principle that the
    # only places camelCase occurs in the filenames are where there were
    # originally space characters separating two words.
    # It also adds spaces between lowercase letters and numbers for the sake
    # of matching.
    PROTO="$(echo "$file" | sed 's/^.*-//;s/\..*$//')"
    CITY="$(echo "$file" | sed 's/-.*$//')"
    CITY="$(echo "$CITY" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g;s/\([a-z]\)\([0-9]\)/\1 \2/g;')"
    # this is needed to fix Washington DC:
    CITYNOSPACE="$(echo "$CITY" | sed 's/ //g')"
    NICKNAME="$(echo "$file" | sed 's/'"$CITYNOSPACE"'-//;s/-.*$//')"
    NICKNAME="$(echo "$NICKNAME" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g;s/\([a-z]\)\([0-9]\)/\1 \2/g')"
    sed 's/REPLACE_WITH_NICKNAME/'"$NICKNAME"'/;s/REPLACE_WITH_CITY/'"$CITY"'/' ../tmp_json.js > proc.js
    # evaluate our javascript
    NEWNAME="$("$JS" ./proc.js)"
    
    # this while...read loop is here because the way I had my Javascript at various
    # points during development it was able to print more than one line out
    # before exiting and coming back to the shell loop.
    echo "$NEWNAME" | while read -r lin; do
      TRUNC="$(echo "$lin" | sed 's/ //g')"
      FULL="$(echo "$TRUNC"'.'"$PROTO"'.ovpn' | sed 's/-\([0-9]\)/\1/')"
      echo "$file"' -> '"$FULL"
      mkdir -p "$WORKDIR"'/'"$DIR"'_procd'
      # Inserts an authentication file path into the output configuration.
      sed 's!auth-user-pass!auth-user-pass '"$AUTHFILE"'!' < "$WORKDIR"'/udp/'"$file" > "$WORKDIR"'/'"$DIR"'_procd/'"$FULL"
      # alternative: symlinks
#      mkdir "$WORKDIR"'/procd'
#      cd "$WORKDIR"'/procd'
#      ln -s "$WORKDIR"'/udp/'"$file" "$WORKDIR"'/procd/'"$FULL"
    done
  done
}
makefiles udp
# not all of those files are available as TCP
#makefiles tcp
#makelinks udp # puts links in "$WORKDIR"'/udp_'
#makelinks tcp
