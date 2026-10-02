# gentoo-overlay

Personal Gentoo overlay (repo name `gentoo-overlay`), shared between my machines.

## Use it

`/etc/portage/repos.conf/gentoo-overlay.conf`:

```ini
[gentoo-overlay]
location = /var/db/repos/gentoo-overlay
sync-type = git
sync-uri = https://github.com/Paulbouchara/gentoo-repo.git
auto-sync = yes
priority = 60
```

Then `emaint sync -r gentoo-overlay`.

Many dependencies live in other overlays, which must be enabled too:
`guru` (quickshell, matugen, fuzzel, cliphist, ananicy-cpp, …) and
`hyproverlay` (Hyprland and its tools, for `gui-apps/ryoku-desktop`).

Released versions are keyworded `~amd64`. Live `9999` ebuilds have no keywords,
so Portage only picks one when asked, e.g. in `package.accept_keywords`:

```
=gui-apps/ryoku-desktop-9999 **
```

## Work on it

Never edit `/var/db/repos/gentoo-overlay` in place: the next sync resets it.
Edit a clone, regenerate the Manifest when `SRC_URI` changes
(`ebuild <file>.ebuild manifest`), commit, push, then sync each machine.
