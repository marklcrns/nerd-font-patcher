#!/usr/bin/env bash

# Credits: https://gist.github.com/ELLIOTTCABLE/5b87ab21b11acb76a5c52d47a022b519

SCRIPTPATH=${BASH_SOURCE%/*}

for font in ${SCRIPTPATH}/*.ttf; do
	fontforge -script font-patcher.py --careful --complete --progressbars "$font"
done
