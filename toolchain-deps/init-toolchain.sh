#!/bin/sh

# check if already installed
if rustup toolchain list | grep -Poq '^esp$'
then
	if test -f toolchain-deps/rust-build/espressif.env.raw
	then
		exit 0
	else
		# toolchain is installed, but we don't know where
		# TODO: figure out a better way of handling this
		rustup toolchain uninstall esp
	fi
fi

echo "Installing esp rustup toolchain"

git submodule update --init

export IDF_TOOLS_PATH=$(pwd)/toolchain-deps/espressif

cd toolchain-deps/rust-build

cargo install cargo-pio ldproxy && ./install-rust-toolchain.sh --export-file export.sh

cat export.sh | cut -c 8- > espressif.env.raw
