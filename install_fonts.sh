#!/bin/bash

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
