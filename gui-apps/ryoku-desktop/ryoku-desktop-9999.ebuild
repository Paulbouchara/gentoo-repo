# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Umbrella ebuild for the "ryoku" rice (neur0map/ryoku-arch). Upstream splits
# the monorepo into ~30 version-pinned Arch packages; this builds every payload
# component (ryoku CLI, the shell/hub/rashin Go daemons, the ryogami wallpaper
# daemon, the ryovm/ryostore helpers, the Ryoku.Blobs C++/Qt6 QML plugin and
# the livewall C daemon) and lays the base config tree under
# /usr/share/ryoku/config that "ryoku materialize" copies into ~/.config.
#
# Since upstream 83ac35cd (2026-09-14) the desktop is compositor-neutral and the
# Hyprland half ships as ryoku-desktop-hyprland (config tree, portal, the
# ryoku-wm-hyprland provider and its Ryoku.Wm.Hyprland QML bridges). This
# ebuild folds that variant in; the niri variant is not packaged.

PYTHON_COMPAT=( python3_{11..13} )

# go-module: for GO111MODULE/GOCACHE/GOMODCACHE defaults, QA_FLAGS_IGNORED and
# go-module_src_configure (go-env_set_compile_environment). Its exported
# src_unpack is overridden below because this is a git monorepo with mixed
# vendored / zero-dep modules, not a single tarballed module.
inherit cmake go-module python-single-r1 readme.gentoo-r1 desktop xdg udev systemd tmpfiles

DESCRIPTION="Ryoku desktop: Hyprland + Quickshell shell, hub and ecosystem"
HOMEPAGE="https://ryoku.dev https://github.com/neur0map/ryoku-arch"

# Upstream has no PMS-clean tag yet (only v0.63.1-beta.19), so ship the live
# ebuild only. When upstream cuts a real vX.Y.Z, add a versioned ebuild with an
# MY_PV mapping and a proper SRC_URI/S/KEYWORDS.
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/neur0map/ryoku-arch.git"
else
	die "no released version is packageable yet; use ${PN}-9999"
fi

# GPL-3+ (repo LICENSE, license=('GPL-3.0-or-later')) plus the licences of the
# Go modules linked into the shipped binaries:
#   BSD     godbus/dbus/v5, golang.org/x/sys        (ryoku, ryoku-shell, ryoku-hub)
#   MIT     BurntSushi/toml                         (ryoku-hub)
#   ISC     coder/websocket                         (ryoku-rashin)
#   OFL-1.1 archivo-black.woff2, //go:embed'd into   (ryoku-rashin)
LICENSE="GPL-3+ BSD MIT ISC OFL-1.1"
SLOT="0"

IUSE="+bluetooth gaming kwallet nautilus nvidia +ocr plasma-integration plymouth"
IUSE+=" +power-profiles sddm security-keys vm zsh"

# All Go modules build fully offline (vendored trees or zero external deps +
# GOPROXY=off), so network-sandbox is a cheap backstop against a proxy hit.
RESTRICT="network-sandbox"

# kde-frameworks/syntax-highlighting:6 is a HARD RDEPEND. The shell QML does
# `import org.kde.syntaxhighlighting` for the Super+S chat code blocks; without
# the org.kde.syntaxhighlighting QML plugin that surface fails to load. It must
# survive a Plasma wipe - see the ewarn in pkg_postinst. It pulls only a few
# tier-1 kde-frameworks and dev-qt/qtdeclarative:6, no Plasma.
RDEPEND="
	${PYTHON_DEPS}
	gui-wm/hyprland
	gui-apps/quickshell
	x11-base/xwayland
	dev-qt/qtbase:6[wayland,opengl,gui,widgets]
	dev-qt/qtdeclarative:6[opengl,svg,widgets]
	dev-qt/qtmultimedia:6[ffmpeg,opengl,qml,wayland]
	dev-qt/qt5compat:6
	dev-qt/qtsvg:6
	dev-qt/qtimageformats:6
	dev-qt/qtwayland:6
	kde-frameworks/syntax-highlighting:6
	media-fonts/otf-space-grotesk
	media-fonts/fraunces
	media-fonts/material-symbols-variable
	media-fonts/symbols-nerd-font
	media-fonts/jetbrains-mono
	media-fonts/noto
	media-fonts/noto-emoji
	media-video/ffmpeg:=
	media-video/pipewire
	media-video/wireplumber
	dev-libs/wayland
	gui-apps/hypridle
	gui-apps/hyprpicker
	gui-apps/hyprsunset
	gui-apps/grim
	gui-apps/slurp
	gui-apps/wl-clipboard
	gui-apps/wl-clip-persist
	gui-apps/fuzzel
	gui-apps/wtype
	gui-apps/wf-recorder
	gui-libs/xdg-desktop-portal-hyprland
	sys-auth/hyprpolkitagent
	sys-apps/xdg-desktop-portal-gtk
	app-misc/cliphist
	app-misc/brightnessctl
	app-misc/ddcutil
	app-misc/fastfetch
	app-misc/jq
	sys-process/btop
	app-shells/fish
	app-shells/starship
	x11-terms/kitty
	app-editors/neovim
	app-misc/yazi
	|| ( media-sound/cava media-sound/libcava )
	media-sound/playerctl
	sci-libs/libqalculate
	media-video/mpv
	media-gfx/imagemagick
	net-misc/curl
	net-misc/yt-dlp
	net-misc/networkmanager
	net-wireless/iw
	net-firewall/nftables
	sys-fs/inotify-tools
	sys-auth/polkit
	sys-auth/rtkit
	sys-power/upower
	x11-misc/matugen
	x11-misc/xdg-utils
	x11-misc/xdg-user-dirs
	x11-libs/libnotify
	x11-libs/gtk+:3
	x11-themes/adw-gtk3
	x11-themes/gnome-themes-standard
	x11-themes/papirus-icon-theme
	x11-themes/adwaita-icon-theme
	x11-themes/bibata-xcursors
	gnome-base/gnome-keyring
	gnome-extra/zenity
	dev-util/desktop-file-utils
	sys-apps/dbus
	bluetooth? ( net-wireless/bluez )
	gaming? (
		gui-wm/gamescope
		games-util/gamemode
	)
	kwallet? ( kde-plasma/kwallet-pam )
	nautilus? (
		gnome-base/nautilus
		dev-python/nautilus-python
	)
	ocr? (
		app-text/tesseract
		app-text/tessdata_fast
		media-gfx/zbar
	)
	plasma-integration? ( kde-plasma/plasma-integration )
	power-profiles? ( || (
		sys-power/power-profiles-daemon
		sys-apps/tuned[ppd]
	) )
	sddm? ( dev-libs/weston )
	security-keys? ( sys-auth/pam_u2f )
	vm? (
		app-emulation/qemu[spice,usbredir]
		app-emulation/libvirt
		app-crypt/swtpm
		net-misc/spice-gtk
		sys-firmware/edk2-bin
		dev-libs/libisoburn
	)
	zsh? (
		app-shells/zsh
		app-shells/zsh-syntax-highlighting
	)
"

# Build-time only: livewall links wayland-client + libav*, the Blobs plugin
# links Qt6 Quick/Multimedia and needs the QML tooling from qtdeclarative and
# qsb from qtshadertools. The heavy runtime set does not belong here.
DEPEND="
	${PYTHON_DEPS}
	dev-libs/wayland
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtmultimedia:6
	dev-qt/qtshadertools:6
	media-video/ffmpeg:=
"

# go-module.eclass adds an unversioned go; the Go modules declare go 1.26.4 and
# GOTOOLCHAIN=local forbids fetching a newer one. cmake/ninja: cmake.eclass.
BDEPEND="
	>=dev-lang/go-1.26.4
	dev-util/wayland-scanner
	dev-libs/wayland-protocols
	virtual/pkgconfig
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtshadertools:6
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# No upstream test suite (PKGBUILD runs none).
RESTRICT+=" test"

# The Blobs QML module - one package-level tree, not per-phase locals.
CMAKE_USE_DIR="${S}/ryoku/shell/plugin"

# Keep the numbered steps and command blocks verbatim in the README.
DISABLE_AUTOFORMATTING=1
DOC_CONTENTS="
Ryoku is installed, but unlike the upstream Arch package this ebuild does NOT
touch your running system. Do the following yourself:

1. Per-user base configuration (safe to re-run; keeps your edits):

     ryoku materialize

   Your session runs this on first login; root cannot do it for you.

2. Login manager. A 'Ryoku' entry is in /usr/share/wayland-sessions (it launches
   /usr/bin/ryoku-session -> dbus-run-session -> start-hyprland; Hyprland finds
   ~/.config/hypr/hyprland.lua on its own). The stock 'Hyprland' entry works too.
   For greetd + ReGreet:

     emerge -av gui-libs/greetd gui-apps/ReGreet
     # systemd:  systemctl enable greetd.service
     # OpenRC:   rc-update add greetd default
     /etc/greetd/config.toml [default_session]:
       command = 'regreet --session-dir /usr/share/wayland-sessions'
       user = 'greeter'

   If you currently use SDDM, disable it first so two DMs do not race
   display-manager.service:  systemctl disable --now sddm.service

   From a bare TTY you can also just run:  ryoku-session

3. System services upstream enabled automatically (enable what you want):

   systemd:
     systemctl enable --now rtkit-daemon.service
     systemctl enable --now bluetooth.service            # USE=bluetooth
     systemctl enable --now power-profiles-daemon.service # or: tuned + tuned-ppd
     systemctl reload systemd-logind                     # applies 10-ryoku-lid.conf
   OpenRC:
     rc-update add rtkit-daemon default   && rc-service rtkit-daemon start
     rc-update add bluetooth default      && rc-service bluetooth start
     rc-update add power-profiles-daemon default && rc-service power-profiles-daemon start

   The lid drop-in needs elogind or systemd-logind; restart that service.

4. Per-user systemd units (upstream ran 'systemctl --global enable'):

     systemctl --user enable --now ryoku-ai-usage.timer
     systemctl --user enable --now ryoku-bluetooth-reset.service   # USE=bluetooth
     systemctl --user enable --now ryoku-rashin.service            # if you use rashin
     systemctl --user enable --now ryoku-eq.service                # PipeWire EQ, optional

   ryoku-bootstrap.service runs 'ryoku materialize' before a login whose config
   was never laid down. /usr/bin/ryoku-session already does that, so enable it
   only for sessions started another way:
     systemctl --global enable ryoku-bootstrap.service

   Enable the system boot guard if you want the update doctor's behaviour:
     systemctl enable ryoku-boot-guard.service

5. One-time hardware tuning (upstream .install ran these; each is idempotent and
   a no-op on hardware it does not apply to - run as root only if relevant):

     ryoku-bluetooth-tune     # tunes /etc/bluetooth/main.conf
     ryoku-wifi-regdom apply  # pins the Wi-Fi regulatory domain (5 GHz)
     ryoku-hw-backlight-fix   # ASUS AMD+NVIDIA panels: acpi_backlight=native
     ryoku-boot-apply         # USE=plymouth: applies the boot splash theme

6. USE=kwallet only: the injected autostart line unlocks KWallet only if
   pam_kwallet5.so is wired into your login PAM stack. For greetd add to
   /etc/pam.d/greetd:
     auth     optional  pam_kwallet5.so
     session  optional  pam_kwallet5.so auto_start kwallet6

Rashin (the local agent daemon) is inert until you run 'ryoku-rashin enable'.
Its upstream prereqs uv/nodejs/prowl-agent are not pulled in; install
dev-python/uv and net-libs/nodejs by hand if you enable it (prowl-agent has no
Gentoo package).

USE=zsh installs the zsh dotfiles but only pulls app-shells/zsh and
app-shells/zsh-syntax-highlighting; zsh-autosuggestions and
zsh-history-substring-search are not packaged for Gentoo, so ryoku.zsh silently
skips them. adw-gtk3 comes from the guru overlay (the autostart selects it by
name); x11-themes/bibata-xcursors covers the configured Bibata-Modern-Ice
pointer.

Not packaged, so the matching feature is unavailable: hyprland-preview-share-picker
(screen-share source picker), the Hyprland compositor plugins the Hub Plugins
page toggles (keysounds/hyprbars/hyprfocus/dynamic-cursors/hyprglass/imgborders),
gpu-screen-recorder (Super+U falls back to the shipped wf-recorder), and the
mpv-mpris script (the '@' live-radio now-playing widget will not follow
playback). Arch-only boot bits (Limine hooks, the mkinitcpio GPU-trim hook) are
intentionally dropped.

Upstream's environment.d/ryoku-session.conf is NOT installed. The systemd user
manager would hand it to every session, KDE Plasma included, where its
QT_QPA_PLATFORMTHEME=qt6ct and fixed PATH break the Plasma theme and Gentoo's
PATH. Hyprland sets the same variables itself from hypr/modules/env.lua.
"

src_unpack() {
	# git-r3 only; the go-module eclass's src_unpack (ego mod verify against a
	# proxy) is for tarballed single modules and would fight the monorepo.
	git-r3_src_unpack
}

src_prepare() {
	cmake_src_prepare

	if use kwallet; then
		# Upstream is a gnome-keyring desktop with no KWallet integration. For a
		# user who keeps KDE Wallet, unlock it on Hyprland start via the PAM
		# helper kde-plasma/kwallet-pam installs. On Gentoo that helper is
		# /usr/libexec/pam_kwallet_init (Arch: /usr/lib); the `test -x` guard
		# makes the injected line a no-op if it is ever absent. GNU sed exits 0
		# on a non-matching address, so grep-guard the anchor both before and
		# after.
		local autostart="${S}/ryoku/hyprland/modules/autostart.lua"
		grep -q 'gnome-keyring-daemon --start' "${autostart}" \
			|| die "kwallet: anchor gone in ${autostart#"${S}"/} (upstream layout changed)"
		sed -i \
			-e '/gnome-keyring-daemon --start/a\    hl.exec_cmd("test -x /usr/libexec/pam_kwallet_init && exec /usr/libexec/pam_kwallet_init")' \
			"${autostart}" || die
		grep -q 'pam_kwallet_init' "${autostart}" \
			|| die "kwallet: sed produced no change in ${autostart#"${S}"/}"
	fi
}

src_configure() {
	# Go env: go-module.eclass gives GO111MODULE/GOCACHE/GOMODCACHE and, via
	# go-module_src_configure -> go-env_set_compile_environment, the standard
	# GOFLAGS (-x -v -modcacherw -buildvcs=false -buildmode=pie), GOARCH/GOOS and
	# the tc-exported CC/CXX. APPEND the offline/vendor knobs so those defaults
	# (PIE in particular) are kept.
	go-module_src_configure
	export GOFLAGS+=" -trimpath -mod=vendor"
	export GOPROXY=off
	export GOSUMDB=off
	export CGO_ENABLED=0
	# GOTOOLCHAIN=local: hub/backend and shell/ipc declare `go 1.26` /
	# `toolchain go1.26.5`; without local an older system Go would try to
	# download a toolchain and be sandbox-killed - a plain build failure is
	# clearer. System Go 1.27+ satisfies the directives.
	export GOTOOLCHAIN=local

	# cmake.eclass default build type (RelWithDebInfo) is fine and keeps
	# FEATURES=splitdebug working; do not override it.
	cmake_src_configure
}

src_compile() {
	# 1. Ryoku.Blobs - C++/Qt6 QML module. cmake.eclass drives Ninja
	#    out-of-source into ${BUILD_DIR}, producing the module dir at
	#    ${BUILD_DIR}/qml/Ryoku/Blobs (.so + qmldir + .qmltypes; shaders are
	#    baked into the .so as Qt resources). Inherits the user's clang +
	#    CXXFLAGS via cmake.eclass; no LTO hazard (default build is no-LTO and
	#    the component is LTO-neutral).
	cmake_src_compile

	# 2. livewall - C11 / Wayland video-wallpaper daemon (installed as
	#    ryoku-livewall, symlinked ryogami-live). wlr-layer-shell references
	#    xdg-shell interfaces at the C level, so all three protocols are
	#    scanned on the build host. -D_GNU_SOURCE is in-source. Built with
	#    $(tc-getCC) (clang here) + the user's CFLAGS/CPPFLAGS/LDFLAGS.
	local proto_dir gen xml name
	proto_dir="$($(tc-getPKG_CONFIG) --variable=pkgdatadir wayland-protocols)" || die
	gen="${T}/livewall-proto"
	mkdir -p "${gen}" || die
	for xml in \
		"${S}/ryoku/shell/livewall/wlr-layer-shell.xml:wlr-layer-shell" \
		"${proto_dir}/stable/viewporter/viewporter.xml:viewporter" \
		"${proto_dir}/stable/xdg-shell/xdg-shell.xml:xdg-shell"
	do
		name="${xml##*:}"
		wayland-scanner private-code  "${xml%:*}" "${gen}/${name}-protocol.c" || die
		wayland-scanner client-header "${xml%:*}" "${gen}/${name}-client-protocol.h" || die
	done

	$(tc-getCC) -std=gnu11 ${CFLAGS} ${CPPFLAGS} -I"${gen}" \
		-o "${T}/ryoku-livewall" \
		"${S}/ryoku/shell/livewall/livewall.c" \
		"${gen}"/wlr-layer-shell-protocol.c \
		"${gen}"/viewporter-protocol.c \
		"${gen}"/xdg-shell-protocol.c \
		$($(tc-getPKG_CONFIG) --cflags --libs \
			wayland-client libavformat libavcodec libavutil libswscale) \
		${LDFLAGS} -lm || die "livewall compilation failed"

	# 3. Go binaries. cli/shell-ipc/hub/rashin carry vendor/ (-mod=vendor via
	#    GOFLAGS); ryogami/ryovm-*/ryostore have go.mod with zero external
	#    requires and build -mod=mod (the explicit flag wins over GOFLAGS),
	#    still offline. CGO_ENABLED=0 so the C toolchain is never invoked.
	local go_bins=(
		"ryoku/cli:ryoku:vendor"
		"ryoku/shell/ipc:ryoku-shell:vendor"
		"ryoku/hub/backend:ryoku-hub:vendor"
		"ryoku/rashin/backend:ryoku-rashin:vendor"
		"ryoku/shell/ryogami/daemon:ryogami:mod"
		"ryoku/apps/ryovm/fetch:ryovm-fetch:mod"
		"ryoku/apps/ryovm/mon:ryovm-mon:mod"
		"ryoku/apps/ryovm/remote:ryossh:mod"
		"ryoku/apps/ryostore/backend:ryostore:mod"
		# the Hyprland provider of the wm seam; the module root (go.mod +
		# vendor/) is ryoku/wm, one level up.
		"ryoku/wm/hyprland:ryoku-wm-hyprland:vendor"
	)
	mkdir -p "${T}/gobin" || die
	local entry dir bin mode
	for entry in "${go_bins[@]}"; do
		dir="${entry%%:*}"
		bin="${entry#*:}"; bin="${bin%%:*}"
		mode="${entry##*:}"
		einfo "Building Go binary ${bin} (-mod=${mode}) in ${dir}"
		pushd "${S}/${dir}" >/dev/null || die
		ego build -mod="${mode}" -o "${T}/gobin/${bin}" .
		popd >/dev/null || die
	done

	# 4. Pre-index the monorepo for rashin's vault: the installed target has no
	#    checkout, so ryoku-repo.md ships as a snapshot built from this tree
	#    with the just-built binary (reads the local tree only, no network).
	"${T}/gobin/ryoku-rashin" repo-index "${S}" "${T}/ryoku-repo.md" \
		|| die "ryoku-rashin repo-index failed"
}

src_install() {
	local cfg="/usr/share/ryoku/config"
	local qmldir="/usr/$(get_libdir)/qt6/qml/Ryoku"

	# --- 1. binaries -----------------------------------------------------------
	dobin "${T}"/gobin/{ryoku,ryoku-shell,ryoku-hub,ryoku-rashin,ryogami,ryovm-fetch,ryovm-mon,ryossh,ryostore,ryoku-wm-hyprland}
	newbin "${T}/ryoku-livewall" ryoku-livewall
	# upstream ships these as separate =$pkgver packages; here they are aliases.
	dosym ryoku-rashin /usr/bin/rashin
	dosym ryoku-livewall /usr/bin/ryogami-live

	# ryoku-i18n: the UI translation tool the Hub and Hyprland autostart call by
	# name (upstream: ryoku/i18n/tools/sync.py, python3 stdlib-only).
	newbin "${S}/ryoku/i18n/tools/sync.py" ryoku-i18n

	# AI-usage collectors (python3 stdlib-only); the qsbar AI pill reads the
	# ~/.cache/*-usage.json they refresh.
	local b
	for b in claude-usage codex-usage opencode-usage; do
		dobin "${S}/ryoku/shell/bin/${b}"
	done

	# ryoku-shell package helpers: every leaf script the bar, launcher, Hub,
	# keybinds and daemon call by bare name (ryoku-app, ryoku-cmd-*, ryoku-eq,
	# ...), the Stash/LocalSend .sh backends, and the ryostage launcher. Same
	# globs as upstream's ryoku-shell PKGBUILD, so a new script needs no edit.
	local s
	for s in "${S}"/ryoku/shell/scripts/{ryoku-*,*.sh,ryostage}; do
		[[ -f ${s} ]] && dobin "${s}"
	done
	insinto /usr/share/ryoku/reload-cover
	doins -r "${S}/ryoku/shell/quickshell/reload-cover/."

	# Hyprland's own leaf scripts (ryoku-monitor, ryoku-workspace, ...), from
	# ryoku-desktop-hyprland. They are ALSO shipped in the config tree below.
	for s in "${S}"/ryoku/hyprland/scripts/ryoku-*; do
		[[ -f ${s} ]] && dobin "${s}"
	done
	dobin "${S}/ryoku/apps/fastfetch/ryoku-fastfetch"
	dobin "${S}/ryoku/shell/quickshell/plugins/ryoku-plugins-place"
	for s in "${S}"/system/hardware/*/ryoku-*; do
		[[ -f ${s} && -x ${s} ]] && dobin "${s}"
	done
	# system/containers/ryoku-docker: the privileged door the stash Cobalt
	# wizard drives (paired with 46-ryoku-docker.rules below).
	for s in "${S}"/system/containers/ryoku-*; do
		[[ -f ${s} ]] && dobin "${s}"
	done
	# system/extras: ryoku-pkg-* and ryostore-install are pacman/AUR wrappers,
	# non-functional on Gentoo and deliberately NOT installed. ryoku-cmd-present
	# is a plain `command -v` probe other helpers call, so it ships.
	dobin "${S}/system/extras/ryoku-cmd-present"

	# --- 2. Ryoku.* QML modules ----------------------------------------------
	# Mirror upstream's whole-dir copy of the built Blobs module.
	insinto "${qmldir}/Blobs"
	doins -r "${BUILD_DIR}/qml/Ryoku/Blobs/."
	local so
	for so in "${ED}${qmldir}/Blobs"/*.so; do
		[[ -f ${so} ]] && fperms 0755 "${qmldir}/Blobs/${so##*/}"
	done

	# Ryoku.Ui / FrameBars / PluginKit: pure QML+JS on the system import path
	# (Quickshell sandboxes relative imports to the config root, so they cannot
	# live inside one root). Prune authoring-time helpers from the source tree
	# before install so the image only ever gets runtime files.
	rm -f "${S}/ryoku/ui/install.sh" \
		"${S}/ryoku/shell/framebars/install.sh" \
		"${S}/ryoku/shell/quickshell/plugins/kit/install.sh" || die
	rm -f "${S}"/ryoku/ui/i18n-*.py || die
	rm -rf "${S}/ryoku/ui/__pycache__" || die
	rm -f "${S}"/ryoku/shell/framebars/*.test.mjs || die

	insinto "${qmldir}/Ui"
	doins -r "${S}/ryoku/ui/."
	insinto "${qmldir}/FrameBars"
	doins -r "${S}/ryoku/shell/framebars/."
	insinto "${qmldir}/PluginKit"
	doins -r "${S}/ryoku/shell/quickshell/plugins/kit/."
	# the provider's QML bridges (global shortcuts, focus grab) the shell
	# imports instead of Quickshell.Hyprland.
	insinto "${qmldir}/Wm/Hyprland"
	doins -r "${S}/ryoku/wm/hyprland/qml/."

	# --- 3. base config tree for `ryoku materialize` -----------------------
	insinto "${cfg}/hypr"
	doins -r "${S}/ryoku/hyprland/."
	# doins flattens to 0644; the shell calls hypr/scripts/* by absolute path.
	# Restore +x on the scripts (not on magick-policy/policy.xml).
	for s in "${S}"/ryoku/hyprland/scripts/*; do
		[[ -f ${s} && -x ${s} ]] && fperms 0755 "${cfg}/hypr/scripts/${s##*/}"
	done

	insinto "${cfg}/quickshell"
	doins -r "${S}/ryoku/shell/quickshell/."
	insinto "${cfg}/quickshell/hub"
	doins -r "${S}/ryoku/hub/quickshell/."
	insinto "${cfg}/quickshell/ryovm"
	doins -r "${S}/ryoku/apps/ryovm/quickshell/."
	insinto "${cfg}/quickshell/ryostore"
	doins -r "${S}/ryoku/apps/ryostore/quickshell/."

	insinto "${cfg}/matugen"
	doins -r "${S}/ryoku/shell/matugen/."

	insinto "${cfg}/xdg-desktop-portal"
	doins "${S}/ryoku/hyprland/hyprland-portals.conf"

	insinto "${cfg}/gtk-3.0"
	doins "${S}/ryoku/shell/gtk-3.0/settings.ini"
	insinto "${cfg}/gtk-4.0"
	doins "${S}/ryoku/shell/gtk-4.0/settings.ini"

	insinto "${cfg}/fish"
	doins "${S}/ryoku/apps/fish/config.fish"
	insinto "${cfg}/fish/conf.d"
	doins "${S}/ryoku/apps/fish/conf.d/rashin.fish"

	insinto "${cfg}/bash"
	doins "${S}/ryoku/apps/bash/ryoku.bash"
	doins "${S}/ryoku/apps/bash/rashin.bash"
	insinto "${cfg}/zsh"
	doins "${S}/ryoku/apps/zsh/ryoku.zsh"
	doins "${S}/ryoku/apps/zsh/rashin.zsh"
	insinto "${cfg}/ryoku-terminal"
	doins "${S}/ryoku/apps/terminal-shell/env.sh"

	insinto "${cfg}/ghostty"
	doins -r "${S}/ryoku/apps/ghostty/."

	insinto "${cfg}/qt6ct"
	doins "${S}/ryoku/shell/qt6ct/qt6ct.conf"
	insinto "${cfg}/btop"
	doins "${S}/ryoku/apps/btop/btop.conf"
	insinto "${cfg}"
	doins "${S}/ryoku/apps/starship/starship.toml"

	insinto "${cfg}/fastfetch"
	doins "${S}/ryoku/apps/fastfetch/config.jsonc"
	newins "${S}/ryoku/assets/brand/fastfetch-emblem.png" fastfetch-emblem.png

	insinto "${cfg}/wireplumber"
	doins -r "${S}/ryoku/apps/wireplumber/."
	insinto "${cfg}/yazi"
	doins "${S}/ryoku/apps/yazi/yazi.toml"
	insinto "${cfg}/kitty"
	doins -r "${S}/ryoku/apps/kitty/."

	insinto "${cfg}/nvim"
	doins "${S}/ryoku/apps/nvim/init.lua"
	doins "${S}/ryoku/apps/nvim/.ryoku-lazyvim"
	doins -r "${S}/ryoku/apps/nvim/lua"

	insinto "${cfg}/pip"
	doins "${S}/ryoku/apps/pip/pip.conf"

	# chromium reads ~/.config/chromium-flags.conf, Chrome reads chrome-flags.conf.
	insinto "${cfg}"
	doins "${S}/ryoku/apps/chromium-flags.conf"
	newins "${S}/ryoku/apps/chromium-flags.conf" chrome-flags.conf

	insinto "${cfg}/hyprland-preview-share-picker"
	doins "${S}/ryoku/apps/hyprland-preview-share-picker/config.yaml"

	# whole systemd/user dir into the config tree (materialized per-user); the
	# runtime unit dir gets the real units below.
	insinto "${cfg}/systemd/user"
	doins -r "${S}/ryoku/shell/systemd/user/."

	# --- 4. QML app assets, wallpapers, decor, lockscreen ----------------
	insinto /usr/share/ryogami
	doins -r "${S}/ryoku/shell/ryogami/wall-ui/."
	domenu "${S}/ryoku/shell/ryogami/wall-ui/data/ryogami-wall.desktop"

	insinto /usr/share/ryoku/ryodecors
	doins -r "${S}/ryoku/assets/ryodecors/."
	insinto /usr/share/ryoku/wallpapers
	doins -r "${S}/ryoku/assets/wallpapers/."

	insinto /usr/share/ryoku/lockscreen/qylock
	doins -r "${S}/ryoku/lockscreen/qylock/."
	exeinto /usr/share/ryoku/lockscreen
	doexe "${S}/ryoku/lockscreen/install-qylock"
	if use sddm; then
		# weston --shell=kiosk SDDM Wayland-greeter wrapper, and the session
		# wrapper that waits for weston to release the GPU. Only useful with SDDM.
		doexe "${S}"/ryoku/lockscreen/sddm/{ryoku-greeter,ryoku-wayland-session}
	fi
	# the lock/unlock helpers the shell and the lock button call by bare name.
	dobin "${S}"/ryoku/lockscreen/{ryoku-qylock-activate,ryoku-qylock-lock}
	dobin "${S}/ryoku/lockscreen/qylock/quickshell-lockscreen/ryoku-qylock-unlock-prepare"

	# browser extension (Ryoku Theme): source plus the two assembled unpacked
	# dirs the browsers load from. Prune the stale dist/ from the source copy.
	rm -rf "${S}/ryoku/browser/dist" || die
	insinto /usr/share/ryoku/browser
	doins -r "${S}/ryoku/browser/."
	local eng
	for eng in chromium firefox; do
		insinto "/usr/share/ryoku/browser/dist/${eng}/src"
		doins "${S}"/ryoku/browser/src/*
		insinto "/usr/share/ryoku/browser/dist/${eng}"
		newins "${S}/ryoku/browser/manifest.${eng}.json" manifest.json
	done

	# translation catalog: the one path every runtime reads. Non-recursive -
	# catalog/overrides/ and catalog.go are not shipped.
	insinto /usr/share/ryoku/i18n
	local j
	for j in "${S}"/ryoku/i18n/catalog/*.json; do
		doins "${j}"
	done
	doins "${S}/ryoku/i18n/langs.json"

	# rashin vault snapshot + the `ryoku` agent skill (`ryoku-rashin wire`
	# symlinks the skill dir into agents' skills dirs).
	insinto /usr/share/ryoku/rashin
	doins "${T}/ryoku-repo.md"
	insinto /usr/share/ryoku/skills/ryoku
	doins "${S}"/ryoku/rashin/skills/ryoku/{SKILL.md,gui.md,bar.md,plugins.md}

	# --- 5. desktop files + icons --------------------------------------
	local d
	for d in "${S}"/ryoku/apps/*/*.desktop "${S}"/ryoku/apps/tools/*.desktop; do
		[[ -f ${d} ]] && domenu "${d}"
	done
	domenu "${S}/ryoku/hub/ryoku-hub.desktop"

	insinto /usr/share/icons/hicolor/scalable/apps
	newins "${S}/ryoku/apps/ryovm/quickshell/logo.svg" ryovm.svg
	newins "${S}/ryoku/apps/ryostore/quickshell/logo.svg" ryostore.svg
	newins "${S}/ryoku/assets/brand/logo-mark.svg" ryoku.svg
	newins "${S}/ryoku/assets/brand/logo.svg" ryoku-hub.svg

	# vendor layer of the XDG mimeapps chain - does NOT clobber a user's
	# ~/.config/mimeapps.list.
	insinto /usr/share/applications
	doins "${S}/ryoku/apps/mimeapps.list"

	insinto /usr/share/nautilus-python/extensions
	doins "${S}/ryoku/apps/nautilus/ryoku-stash-menu.py"

	# --- 6. udev / polkit / modprobe / modules-load / logind ---------
	udev_dorules \
		"${S}/system/hardware/gpu/90-ryoku-gpu.rules" \
		"${S}/system/hardware/display/90-ryoku-backlight.rules" \
		"${S}/system/hardware/ddc/60-ryoku-i2c.rules" \
		"${S}/system/hardware/audio/70-ryoku-maono.rules" \
		"${S}/system/hardware/input/72-ryoku-keyboard-uaccess.rules" \
		"${S}/system/hardware/input/62-ryoku-qmk-hid.rules"

	# sys-auth/polkit JS rules engine re-reads this dir on change.
	insinto /usr/share/polkit-1/rules.d
	doins "${S}"/system/hardware/network/4[89]-ryoku-*.rules
	doins "${S}"/system/hardware/network/5[015]-ryoku-*.rules
	doins "${S}/system/hardware/power/47-ryoku-power.rules"
	doins "${S}/system/hardware/gpu/45-ryoku-gpu-mux.rules"
	doins "${S}/system/hardware/power/53-ryoku-game-tune.rules"
	doins "${S}/system/hardware/bluetooth/54-ryoku-bluetooth-a2dp.rules"
	doins "${S}/system/containers/46-ryoku-docker.rules"
	doins "${S}/system/policy/52-ryoku-timedate.rules"

	# vendor default module options: Gentoo path is /usr/lib/modprobe.d.
	insinto /usr/lib/modprobe.d
	doins "${S}/system/hardware/audio/99-ryoku-audio-powersave.conf"
	doins "${S}/system/hardware/input/99-ryoku-controller.conf"
	doins "${S}/system/hardware/bluetooth/99-ryoku-bt-autosuspend.conf"

	# modules-load.d: upstream targets /etc (fixed hardware requirement of the
	# desktop); keep that path.
	insinto /etc/modules-load.d
	doins "${S}/system/hardware/ddc/ryoku-i2c.conf"
	doins "${S}/system/hardware/input/99-ryoku-uinput.conf"

	# elogind / systemd-logind clamshell drop-in.
	insinto /etc/systemd/logind.conf.d
	newins "${S}/system/hardware/power/logind-ryoku-lid.conf" 10-ryoku-lid.conf

	# --- 7. systemd units ----------------------------------------
	systemd_dounit \
		"${S}/ryoku/cli/systemd/ryoku-boot-guard.service" \
		"${S}/system/hardware/network/ryoku-network-kill-guard.service" \
		"${S}/system/hardware/network/ryoku-network-kill-disconnect.service"

	newtmpfiles "${S}/ryoku/cli/systemd/ryoku.tmpfiles.conf" ryoku.conf

	# resolves the localized XDG_*_DIR from user-dirs.dirs at login, so the
	# shell's Pictures/Downloads roots follow a non-English home. Only exports
	# the user's own dirs, safe for every session. (environment.d/
	# ryoku-session.conf is deliberately skipped, see DOC_CONTENTS.)
	exeinto /usr/lib/systemd/user-environment-generators
	doexe "${S}/ryoku/shell/systemd/user-environment-generators/60-ryoku-xdg-dirs"

	systemd_douserunit \
		"${S}/ryoku/shell/systemd/user/ryoku-shell.service" \
		"${S}/ryoku/shell/systemd/user/ryogami.service" \
		"${S}/ryoku/shell/systemd/user/ryoku-eq.service" \
		"${S}/ryoku/shell/systemd/user/ryoku-ai-usage.service" \
		"${S}/ryoku/shell/systemd/user/ryoku-ai-usage.timer" \
		"${S}/ryoku/shell/systemd/user/ryoku-bootstrap.service" \
		"${S}/ryoku/shell/systemd/user/ryoku-session.target" \
		"${S}/ryoku/rashin/systemd/ryoku-rashin.service" \
		"${S}/system/hardware/bluetooth/ryoku-bluetooth-reset.service"

	# --- 8. /etc/ryoku-release -------------------------------
	# `ryoku version`/`status`, the update island and doctor read this. No DATE=
	# line (would bake wall-clock time into an installed file - non-reproducible).
	local codename
	codename=$(<"${S}/CODENAME") || die "CODENAME missing"
	cat > "${T}/ryoku-release" <<-EOF || die
		RELEASE=local-${PVR}
		NAME=${codename//[[:space:]]/}
		CHANNEL=local
		VERSION=${PV}
		COMMIT=${EGIT_VERSION:-unknown}
	EOF
	insinto /etc
	doins "${T}/ryoku-release"

	# --- 9. Plymouth theme (USE=plymouth) -------------------
	if use plymouth; then
		insinto /usr/share/plymouth/themes/ryoku
		doins -r "${S}/system/boot/plymouth/ryoku/."
		dobin "${S}/system/boot/ryoku-boot-apply"
	fi

	# Not ported: system/boot/mkinitcpio/install/ryoku-gpu-trim (Arch initramfs
	# only) and the Limine boot hooks (system/boot/limine/*) - Gentoo users pick
	# their own bootloader.

	# --- 10. wayland session entry + launcher --------------
	# Upstream ships NO session .desktop; its installer reuses the stock
	# hyprland.desktop and Hyprland auto-loads ~/.config/hypr/hyprland.lua. We
	# add a branded 'Ryoku' entry that runs a thin wrapper: it materializes the
	# config on first login, then hands off exactly the way the stock entry does
	# (start-hyprland with no args - Hyprland finds hyprland.lua itself;
	# `start-hyprland --config X` does NOT work, start-hyprland only forwards
	# args after a literal `--`). dbus-run-session gives the session a private
	# bus when the DM did not (mirrors hyprland-dbus-run-session-if-needed).
	insinto /usr/share/wayland-sessions
	newins - ryoku.desktop <<-EOF || die
		[Desktop Entry]
		Name=Ryoku
		Comment=Ryoku Wayland Desktop Session (Hyprland + Quickshell)
		Exec=/usr/bin/ryoku-session
		Type=Application
		DesktopNames=Hyprland
		Keywords=tiling;wayland;compositor;ryoku;hyprland;quickshell;
	EOF

	cat > "${T}/ryoku-session" <<-'EOF' || die
		#!/bin/bash
		# Ryoku Wayland session launcher (see the ebuild for why it is shaped
		# this way). Materialize the base config on first login, then start
		# Hyprland the way gui-wm/hyprland's own session entry does.
		export XDG_CURRENT_DESKTOP=Hyprland
		export XDG_SESSION_DESKTOP=Hyprland
		export XDG_SESSION_TYPE=wayland

		conf="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua"
		if [ ! -f "$conf" ] && command -v ryoku >/dev/null 2>&1; then
			ryoku materialize >/dev/null 2>&1 || true
		fi

		# Hyprland auto-detects hyprland.lua; no --config needed (and
		# start-hyprland would drop it - it only forwards args after `--`).
		if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && command -v dbus-run-session >/dev/null 2>&1; then
			exec dbus-run-session -- /usr/bin/start-hyprland "$@"
		fi
		exec /usr/bin/start-hyprland "$@"
	EOF
	dobin "${T}/ryoku-session"

	# python3 stdlib-only helpers: pin the interpreter to the chosen impl.
	python_fix_shebang -q \
		"${ED}/usr/bin/ryoku-i18n" \
		"${ED}/usr/bin/claude-usage" \
		"${ED}/usr/bin/codex-usage" \
		"${ED}/usr/bin/opencode-usage"

	readme.gentoo_create_doc
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	# upstream _refresh(): hicolor icon cache + desktop/mime databases.
	xdg_pkg_postinst
	# shipped udev rules apply without a reboot.
	udev_reload
	# create the ryoku-boot-guard marker + boot-ok paths.
	tmpfiles_process ryoku.conf
	readme.gentoo_print_elog

	ewarn "kde-frameworks/syntax-highlighting:6 is a HARD dependency of ryoku-desktop"
	ewarn "(the shell's Super+S chat imports org.kde.syntaxhighlighting). It is NOT"
	ewarn "Plasma - do not let it be depcleaned when you remove kde-plasma/*."
	ewarn ""
	ewarn "The network kill-switch units ship DISABLED. Arm them ONLY through the"
	ewarn "Ryoku Hub / ryoku-network-kill - a hand-enabled guard unit can cut all"
	ewarn "networking on the next boot."
}

pkg_postrm() {
	# upstream post_remove() is _refresh() only.
	xdg_pkg_postrm
	udev_reload
}