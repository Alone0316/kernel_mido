#!/bin/bash
set -e
USER_AGENT="WireGuard-AndroidROMBuild/0.3 ($(uname -a))"

while read -r distro package version _; do
	if [[ $distro == upstream && $package == linuxcompat ]]; then
		VERSION="$version"
		break
	fi
done < <(curl -A "$USER_AGENT" -LSs --connect-timeout 30 https://build.wireguard.com/distros.txt)

rm -rf drivers/net/wireguard
mkdir -p drivers/net/wireguard
curl -A "$USER_AGENT" -LsS --connect-timeout 30 "https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat-$VERSION.tar.xz" | tar -C "drivers/net/wireguard" -xJf - --strip-components=2 "wireguard-linux-compat-$VERSION/src"
sed -i 's/tristate/bool/;s/default m/default y/;' drivers/net/wireguard/Kconfig
git add drivers/net/wireguard && git commit -s --message="wireguard: Update to version ${VERSION}"