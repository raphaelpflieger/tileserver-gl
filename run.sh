#!/bin/bash

_term() {
	echo "Caught signal, stopping gracefully"
	kill -TERM "$child" 2>/dev/null
}

trap _term TERM

# Delete files if they were not cleaned by last run
rm -rf /tmp/.X11-unix /tmp/.X99-lock

start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset
echo "Waiting 3 seconds for xvfb to start..."
sleep 3

export DISPLAY=:99.0

if [ ! -d /vagrant ]; then
	/usr/local/src/mbtiles
	node /usr/local/src/tileserver-gl -c /usr/local/src/config/tsgl_prod.json -p 8080 "$@" &
	child=$!
	wait "$child"
else
	cd /vagrant/mbtiles
	node /usr/local/src/tileserver-gl --verbose -c /vagrant/config/tsgl_dev.json -p 8080 "$@" &
	child=$!
	wait "$child"	
fi


start-stop-daemon --stop --retry 5 --pidfile ~/xvfb.pid # stop xvfb when exiting
rm ~/xvfb.pid
