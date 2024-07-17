# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake

RESTRICT="mirror"
QTMIN=6.6.2
KFMIN=6.3.0

DESCRIPTION="The Linux perf GUI for performance analysis."
HOMEPAGE="https://github.com/KDAB/hotspot"
SRC_URI="
	https://github.com/KDAB/hotspot/releases/download/v${PV}/${PN}-v${PV}.tar.gz
	https://github.com/KDAB/hotspot/releases/download/v${PV}/${PN}-perfparser-v${PV}.tar.gz -> ${PN}-v${PV}-perfparser.tar.gz
	https://github.com/KDAB/hotspot/releases/download/v${PV}/${PN}-PrefixTickLabels-v${PV}.tar.gz -> ${PN}-v${PV}-PrefixTickLabels.tar.gz
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
REQUIRE_USE=""

RDEPEND="
	>=dev-qt/qtbase-${QTMIN}:6=[network,widgets]
	virtual/libelf
	sys-devel/gettext
	sys-devel/binutils
	>=kde-frameworks/extra-cmake-modules-${KFMIN}
	>=kde-frameworks/threadweaver-${KFMIN}
	>=kde-frameworks/ki18n-${KFMIN}
	>=kde-frameworks/kconfigwidgets-${KFMIN}
	>=kde-frameworks/kcoreaddons-${KFMIN}
	>=kde-frameworks/kitemviews-${KFMIN}
	>=kde-frameworks/kitemmodels-${KFMIN}
	>=kde-frameworks/kio-${KFMIN}
	>=kde-frameworks/solid-${KFMIN}
	>=kde-frameworks/kwindowsystem-${KFMIN}
	>=kde-frameworks/kparts-${KFMIN}
	dev-util/perf
	>=dev-libs/kddockwidgets-2.1.0
	"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${PN}-v${PV}.tar.gz
	tar -xf "${DISTDIR}/${PN}-v${PV}-perfparser.tar.gz" --strip-components=1 -C "${S}/3rdparty/perfparser" || die
	tar -xf "${DISTDIR}/${PN}-v${PV}-PrefixTickLabels.tar.gz" --strip-components=1 -C "${S}/3rdparty/PrefixTickLabels" || die
}

src_prepare() {
	# Gentoo doesn't s upport debuginfod, Hotspot doesn't have an option to disable that yet.
	sed -i '/target_link_libraries(libhotspot-perfparser PRIVATE ${LIBDEBUGINFOD_LIBRARIES})/d' 3rdparty/perfparser.cmake \
			|| die "sed failed for perfparser"
	sed -i '/target_compile_definitions(libhotspot-perfparser PRIVATE HAVE_DWFL_GET_DEBUGINFOD_CLIENT=1)/d' 3rdparty/perfparser.cmake \
			|| die "sed failed for perfparser"

	eapply_user
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DQT6_BUILD=true
		# https://github.com/KDAB/hotspot/issues/662
		-DCMAKE_DISABLE_FIND_PACKAGE_QCustomPlot=true
	)
	cmake_src_configure
}

