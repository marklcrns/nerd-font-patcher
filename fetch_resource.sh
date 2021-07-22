#!/usr/bin/env bash

BRANCH="master"

SCRIPTPATH=${BASH_SOURCE%/*}

curl -o ${SCRIPTPATH}/font-patcher.py -JO -fsSl --proto-redir -all,https https://raw.githubusercontent.com/ryanoasis/nerd-fonts/${BRANCH}/{font-patcher}

svn checkout https://github.com/ryanoasis/nerd-fonts/branches/${BRANCH}/src/glyphs ${SCRIPTPATH}/src/glyphs
