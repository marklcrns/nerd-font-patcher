#!/usr/bin/env bash

# Dependencies:
# - fontforge http://designwithfontforge.com/en-US/Installing_Fontforge.html
# - python configparser `pip install configparser`
# - Run fetch_resources.sh

SCRIPTPATH=${BASH_SOURCE%/*}

for font in ${SCRIPTPATH}/*.ttf; do
	fontforge -script font-patcher.py --careful --complete --progressbars "$font"
done
