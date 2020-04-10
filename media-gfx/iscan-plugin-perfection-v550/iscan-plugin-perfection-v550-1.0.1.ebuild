EAPI="6"

inherit rpm

BUNDLE_NAME="iscan-perfection-v550-bundle"
BUNDLE_VERSION="2.30.4"

DESCRIPTION="Epson Perfection V550 PHOTO scanner plugin for SANE 'epkowa' backend."
HOMEPAGE="http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX"
SRC_URI=" amd64? ( https://download2.ebz.epson.net/iscan/plugin/perfection-v550/rpm/x64/${BUNDLE_NAME}-${BUNDLE_VERSION}.x64.rpm.tar.gz )
	x86? ( https://download2.ebz.epson.net/iscan/plugin/perfection-v550/rpm/x86/${BUNDLE_NAME}-${BUNDLE_VERSION}.x86.rpm.tar.gz ) "

LICENSE="AVASYS"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND=">=media-gfx/iscan-2.30.0"
RDEPEND="${DEPEND}"

src_unpack() {
	default

	local RPM_LOCATION="${WORKDIR}/${BUNDLE_NAME}-${BUNDLE_VERSION}.${ARCH/amd/x}.rpm"
	local PLATFORM="x86_64"

	if use x86; then
		PLATFORM="i386"
	fi

	mkdir "${WORKDIR}/${P}" || die "failure create directory"
	rpm2tar -O "${RPM_LOCATION}/plugins/${P}-1.${PLATFORM}.rpm" | tar xf - -C "${WORKDIR}/${P}" || die "failure unpacking ${a}"
}

src_install() {
	dodir /usr/share
	cp -aR "${S}"/usr/share "${ED}"/usr

	dodir /usr/$(get_libdir)
	cp -a "${S}"/usr/lib*/* "${ED}"/usr/$(get_libdir)
}
