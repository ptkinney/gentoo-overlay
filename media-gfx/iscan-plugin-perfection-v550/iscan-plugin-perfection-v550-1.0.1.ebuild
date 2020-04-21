# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

FIRMWARE="esfweb.bin"

DESCRIPTION="Epson Perfection V550 PHOTO scanner plugin for EPSON scanners (nonfree)"

HOMEPAGE="http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX"
# This is distributed as part of the "bundle driver"; since we already have the
# opensource part separately we just install the nonfree part here.

ISCAN_VERSION="2.30.4"

SRC_URI="https://download2.ebz.epson.net/iscan/plugin/perfection-v550/deb/x64/iscan-perfection-v550-bundle-${ISCAN_VERSION}.x64.deb.tar.gz"

LICENSE="EPSON-2018"

SLOT="0"

KEYWORDS="~amd64"
# No keywords since I havent really gotten it to work yet. However, installation
# locations are clearly correct... may be a hardware/network problem on my side.

RESTRICT="bindist mirror strip"

RDEPEND="media-gfx/iscan"
BDEPEND="app-arch/deb2targz"

src_unpack() {
	default
	mv ./iscan-perfection-v550-bundle-${ISCAN_VERSION}.x64.deb/plugins/iscan-plugin-perfection-v550_*_amd64.deb ${P}.deb || die
	mkdir ${P} || die
	cd ${P} || die
	unpack ../${P}.deb
	unpack "${S}/data.tar.gz"
}

src_install() {
	exeinto /usr/lib/iscan
	doexe usr/lib/iscan/*

	insinto /usr/share/iscan-data/device
	doins usr/share/iscan-data/device/*.xml

	insinto /usr/share/iscan
	doins usr/share/iscan/*.bin

	gunzip usr/share/doc/iscan-plugin-perfection-v550/*.gz
	dodoc usr/share/doc/iscan-plugin-perfection-v550/*
}

pkg_setup() {
	basecmds=(
		"iscan-registry --COMMAND interpreter usb 0x04b8 0x013b /usr/lib/iscan/libiscan-plugin-perfection-v550 /usr/share/iscan/${FIRMWARE}"
	)
}

pkg_postinst() {
	elog
	elog "Firmware file ${FIRMWARE} for ${SCANNER}"
	elog "has been installed in /usr/share/iscan."
	elog

	# Only register scanner on new installs
	[[ -n ${REPLACING_VERSIONS} ]] && return

	# Needed for scanner to work properly.
	if [[ ${ROOT} == "/" ]]; then
		for basecmd in "${basecmds[@]}"; do
			eval ${basecmd/COMMAND/add}
		done
		elog "New firmware has been registered automatically."
		elog
	else
		ewarn "Unable to register the plugin and firmware when installing outside of /."
		ewarn "execute the following command yourself:"
		for basecmd in "${basecmds[@]}"; do
			ewarn "${basecmd/COMMAND/add}"
		done
	fi
}

pkg_prerm() {
	# Only unregister on on uninstall
	[[ -n ${REPLACED_BY_VERSION} ]] && return

	if [[ ${ROOT} == "/" ]]; then
		for basecmd in "${basecmds[@]}"; do
			eval ${basecmd/COMMAND/remove}
		done
	else
		ewarn "Unable to register the plugin and firmware when installing outside of /."
		ewarn "execute the following command yourself:"
		for basecmd in "${basecmds[@]}"; do
			ewarn "${basecmd/COMMAND/remove}"
		done
	fi
}
