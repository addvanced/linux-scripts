#!/bin/bash

# Check if netselect is already installed
if ! dpkg -s netselect >/dev/null 2>&1; then
    # If not installed, proceed with download and installation
    ARCH=$(dpkg --print-architecture) # system architecture (e.g., amd64)
    VERSION='0.3.ds1-30.2'
    URL="http://ftp.debian.org/debian/pool/main/n/netselect/netselect_${VERSION}_${ARCH}.deb"
    
    wget $URL
    
    apt install -y ./netselect_${VERSION}_${ARCH}.deb
else
    echo "netselect is already installed."
fi

# Fetch the HTML list of Ubuntu mirrors and extract URLs of up-to-date mirrors
wget -q -O- https://launchpad.net/ubuntu/+archivemirrors > mirrors.txt
awk '
/\/ubuntu\/\+mirror\// { 
    if (block) { print block; block = "" }
    in_block = 1
}
in_block { block = block $0 ORS }
/<\/tr>/ { 
    if (in_block && block ~ /statusUP/) { print block; block = ""; in_block = 0 }
}
END { if (block ~ /statusUP/) print block }
' mirrors.txt | grep -o -P "(f|ht)tp://[^\"]*" > filtered_mirrors.txt

rm -f mirrors.txt

echo "Testing mirrors for speed..."
netselect -s10 -t20 $(cat filtered_mirrors.txt)
