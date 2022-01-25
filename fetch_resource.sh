#!/usr/bin/env bash

if ! command -v curl &> /dev/null; then
  echo "E: Install curl"
  exit 1
fi

if ! command -v svn &> /dev/null; then
  echo "E: Install svn"
  exit 1
fi

BRANCH="master"
SCRIPTPATH=${BASH_SOURCE%/*}

# Fetch font-patcher.py
curl -o ${SCRIPTPATH}/font-patcher.py -JO -fsSl --proto-redir -all,https https://raw.githubusercontent.com/ryanoasis/nerd-fonts/${BRANCH}/{font-patcher}
[[ -e "${SCRIPTPATH}/font-patcher.py" ]] && chmod +x "${SCRIPTPATH}/font-patcher.py"

# Fetch nerd-font src
svn checkout https://github.com/ryanoasis/nerd-fonts/trunk/src/glyphs ${SCRIPTPATH}/src/glyphs
