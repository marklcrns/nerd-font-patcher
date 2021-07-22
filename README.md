# Nerd Font Patcher

[Nerd Font](https://github.com/ryanoasis/nerd-fonts) patcher script for patching
fonts in bulk.

## Dependencies

- [fontforge](http://designwithfontforge.com/en-US/Installing_Fontforge.html)
- python 2 or 3
  - `configparser` -- `pip install configparser`
- Nerd font resources (optional). Run `./fetch_resources.sh`

## Usage

Copy `patcher.sh` script and `src` directory into the same directory as the
fonts to be patched. Then run:

```bash
./patcher.sh
```
