# Nerd Font Patcher

[Nerd Font](https://github.com/ryanoasis/nerd-fonts) patcher script for patching
fonts in bulk.

## Dependencies

- Docker
- Fonts to patch in `./fonts` directory

## Usage

```bash
# Patch fonts in ./fonts and output to ./fonts-patched
# NOTE: the script is not recursive, so fonts in subdirectories will not be patched
docker run --rm -v ./fonts:/in -v ./fonts-patched:/out <docker-image> --careful --complete --progressbars

# Or simply run using existing docker image marklcrns/font-patcher:1.0
./patcher
```

## Docker build

To rebuild the docker image with fresh dependencies, run:

```bash
# Fetch latest version of Nerd Font dependencies
./fetch-resource

# Build docker image
docker build .

# ALTERNATIVE: Tag docker image
docker build -t marklcrns/font-patcher:v1.0 .
``````

