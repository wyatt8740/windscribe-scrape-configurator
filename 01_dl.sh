#! /bin/sh
PYTHON='python3'
WINDVPN="$HOME"'/windvpn/'  # must have trailing slash
ln -sf "$WINDVPN"'windscribe-ovpn-config-scraper/exports' "$WINDVPN"'scraped'
cd '/home/wyatt/windvpn/windscribe-ovpn-config-scraper'
echo '1) Go to: https://windscribe.com/getconfig/openvpn - log in if necessary.'
echo '2) While monitoring HTTP headers, download a config file.'
echo "3) Copy the 'Cookie:' header contents from the outgoing POST request, and paste"
echo '   it here. then press return.'

#echo 'Now attempting to start Seamonkey automatically for you.'

echo '   If no cookie is entered and return is pressed, I will attempt to use'
echo '   an old, hardcoded, and probably invalid cookie automatically.'

read -r COOKIE
if [ -z "$COOKIE" ]; then
  "$PYTHON" './scraper.py' 'ref=https%3A%2F%2Fwindscribe.com%2F; __stripe_mid=1e02e4a9-5191-4a39-8f00-0949c84a3f5b8f3524; i_can_has_cookie=1; ws_session_auth_hash=132135915%3A1%3A1641605832%3Aec832520df1d3003fedefc30ad236ec1dba480a43c%3A486fb969d20bfc0df7b5340ecc1bb48139b874c39d'
else
  "$PYTHON" './scraper.py' "$COOKIE"
fi

1>&2 echo 'FIXME: We are assuming that worked and proceeding without checking.'
echo 'Finished.'
#cd "$WINDVPN"
