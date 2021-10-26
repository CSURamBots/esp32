#!/bin/sh

# check if already installed
if rustup toolchain list | grep -Poq '^esp$'
then
	exit 0
fi

echo "Installing esp rustup toolchain"

git submodule update --init

export IDF_TOOLS_PATH=$(pwd)/toolchain-deps/espressif

cd toolchain-deps/rust-build

cargo install cargo-pio ldproxy && ./install-rust-toolchain.sh --export-file export.sh

cat export.sh | cut -c 8- > espressif.env.raw
