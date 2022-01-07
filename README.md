Windscribe OpenVPN, Simplified (in my opinion).

Why Windscribe tries to make it so hard to have a nice set of VPN configs is
beyond me. I like to shuffle which one I use regularly, and having to go
through the site every time and click through multiple drop-downs is supremely
frustrating to me. And even then it doesn't explicitly say what country each
server is in unless you happen to know that Adelaide is in Australia, or
Tbilisi in Georgia, or Siauliai in Lithuania.

At the risk of being a stereotypical American, I'll admit I don't know the
names of many countries on that list.

This is a script (well, two, really) that batch rename Windscribe OpenVPN
config files scraped via [this nifty web scraper](https://github.com/wilmardo/windscribe-ovpn-config-scraper.git).

Basically, it looks up some information from a JSON file on the Windscribe
servers, to make the file names more descriptive.

Oh, and you can't directly use the info from that JSON to construct working
OpenVPN files, thanks to them having the wrong Common Name (CN) values. It
may be possible to make it work by pinging the servers and checking what they
report as their common names, but I don't know enough about the implementation
of TLS/SSL to really know how to fetch those programmatically.

No longer do I have to figure out which cities are in the country I want my
exit node to be located in. They are made part of the file name.

This is set up a little weirdly, just because I wanted it to be compatible with
as many different Javascript interpreters as possible if I have to parse JSON.
I tested this using Duk, which doesn't even feature standard input or file I/O.

To that end, the shell script (which I _think_ is free of bash-isms and aims
for POSIX) drops strings into the javascript file itself to change operating
parameters.

I think the code is pretty tidy, but it is very sed and regex-heavy. It may
also be somewhat confusing, due to the way it manipulates text.

### How to use

run `install.sh`, after scraping files and putting them in a directory called
`scraped` under the working path defined in the script.



