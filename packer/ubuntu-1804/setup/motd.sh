#!/bin/sh -eux

fsglab="
This system is built by Joe Houghes for the GFSGLAB.

 _____ _____ _____ __    _____ _____
|   __|   __|   __|  |  |  _  | __  |
|   __|__   |  |  |  |__|     | __ -|
|__|  |_____|_____|_____|__|__|_____|


 _____     _      _   _          ___ _
|  _  |_ _| |_   | |_| |_ ___   |  _|_|___ ___
|   __| | |  _|  |  _|   | -_|  |  _| |  _| -_|
|__|  |___|_|    |_| |_|_|___|  |_| |_|_| |___|

        _                                 _ _
 ___ _ _| |_    _ _ ___ ___ ___    ___ _ _|_| |_
| . | | |  _|  | | | . | . |   |  | -_|_'_| |  _| _
|___|___|_|    |___|  _|___|_|_|  |___|_,_|_|_|  |_|
                   |_|

"

if [ -d /etc/update-motd.d ]; then
    MOTD_CONFIG='/etc/update-motd.d/99-fsglab'

    cat >> "$MOTD_CONFIG" <<FSGLAB
#!/bin/sh

cat <<'EOF'
$fsglab
EOF
FSGLAB

    chmod 0755 "$MOTD_CONFIG"
else
    echo "$fsglab" >> /etc/motd
fi
