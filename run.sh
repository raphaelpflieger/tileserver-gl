#!/bin/bash

_term() {
	echo "Caught signal, stopping gracefully"
	kill -TERM "$child" 2>/dev/null
}

trap _term SIGTERM
trap _term SIGINT

xvfbMaxStartWaitTime=5
displayNumber=99
screenNumber=0

# Delete files if they were not cleaned by last run
rm -rf /tmp/.X11-unix /tmp/.X${displayNumber}-lock ~/xvfb.pid

echo "Starting Xvfb on display ${displayNumber}"
start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :${displayNumber} -screen ${screenNumber} 1024x768x24  -ac +extension GLX +render -noreset

# Wait to be able to connect to the port. This will exit if it cannot in 15 minutes.
timeout ${xvfbMaxStartWaitTime} bash -c "while  ! xdpyinfo -display :${displayNumber} >/dev/null; do sleep 0.5; done"
if [ $? -ne 0 ]; then
  echo "Could not connect to display ${displayNumber} in ${xvfbMaxStartWaitTime} seconds time."
  exit 1
fi

export DISPLAY=:${displayNumber}.${screenNumber}

echo
cd /data

# Install TileServer GL assets
#-----------------------------

if [ ! -d "assets" ]; then

	mkdir -p assets/fonts
	mkdir -p assets/styles
	wget -qO- https://github.com/openmaptiles/fonts/releases/download/v2.0/v2.0.zip | bsdtar -xvf- -C assets/fonts

	for style in dark-matter klokantech-basic osm-bright klokantech-terrain; do
		mkdir -p assets/styles/$style
		wget -qO- https://github.com/openmaptiles/$style-gl-style/releases/download/v1.4/v1.4.zip | bsdtar -xvf- -C assets/styles/$style;
	done

	git clone https://github.com/klokantech/klokantech-gl-fonts.git
	cd klokantech-gl-fonts

	# We need to rename fonts, issue with Klokantech package namespace
	mv ./KlokanTech\ Noto\ Sans\ Bold ../assets/fonts/Klokantech\ Noto\ Sans\ Bold
	mv ./KlokanTech\ Noto\ Sans\ CJK\ Bold ../assets/fonts/Klokantech\ Noto\ Sans\ CJK\ Bold
	mv ./KlokanTech\ Noto\ Sans\ CJK\ Regular ../assets/fonts/Klokantech\ Noto\ Sans\ CJK\ Regular
	mv ./KlokanTech\ Noto\ Sans\ Italic ../assets/fonts/Klokantech\ Noto\ Sans\ Italic
	mv ./KlokanTech\ Noto\ Sans\ Regular ../assets/fonts/Klokantech\ Noto\ Sans\ Regular

	cd ..
	rm -r klokantech-gl-fonts

fi

node /usr/src/app/ --verbose -c /usr/src/app/config.json -p 80 "$@" &
child=$!
wait "$child"

start-stop-daemon --stop --retry 5 --pidfile ~/xvfb.pid # stop xvfb when exiting
rm ~/xvfb.pid
