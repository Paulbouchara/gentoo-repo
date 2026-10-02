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

Most packages are keyworded `~amd64` only, and several are live (`9999`) ebuilds.

## Work on it

Never edit `/var/db/repos/gentoo-overlay` in place: the next sync resets it.
Edit a clone, regenerate the Manifest when `SRC_URI` changes
(`ebuild <file>.ebuild manifest`), commit, push, then sync each machine.
