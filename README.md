# Homebrew tap for hydo

This tap installs [hydo](https://github.com/kakoc/hydo) on Apple Silicon Macs (M1 or later)
with macOS 13 or later. hydo runs a whole system (your services, their databases and queues,
and the workload that drives them) in a virtual machine whose execution is bit-for-bit
deterministic, injects faults from a seed, and shrinks every failure to a short schedule string
that replays exactly.

## Install

```sh
brew install kakoc/tap/hydo
hydo doctor
```

`brew install kakoc/tap/hydo` adds this tap and installs the formula in one step
(`brew tap kakoc/tap` first works as well). The formula installs the prebuilt Mac release
from the [GitHub releases](https://github.com/kakoc/hydo/releases) of hydo, checked by its
sha256. After the files are in place, the formula runs `hydo setup`, which checks every file
against the release's `SHA256SUMS` and against the sha256 pins built into hydo, and signs the
virtual-machine engine (`bin/hydo-hvm`) on your Mac with the hypervisor entitlement. If that step
did not complete, run `hydo setup` yourself. `hydo doctor` then checks the Mac and the
installation; on a complete installation it ends with `doctor: all checks passed`.

## Where the files are

The whole release is in `$(brew --prefix hydo)/libexec`, laid out as the release tarball is:
the programs in `bin/`, the guest kernels and guest files, the onboarding skill, the documents
(`QUICKSTART-mac.md`, `THIRD-PARTY.md`, `LICENSE`, `licenses/`) and the examples. Homebrew links
`hydo`, `hydo-build` and `hydo-fetch-image` into its `bin` directory. The quickstart's
`~/.hydo` is this `libexec` directory under Homebrew, so its first example starts with:

```sh
cp -R "$(brew --prefix hydo)/libexec/examples/redis" ~/hydo-redis && cd ~/hydo-redis
hydo build hydo.yaml
hydo run "disk=none | run"
```

`brew uninstall hydo` removes everything the formula and `hydo setup` wrote. The images, runs and
explorations hydo writes into your own directories (`hydo-out/`) stay where you made them.

## Licenses

The formula and this tap are licensed under the Apache License 2.0 (`LICENSE`). hydo is
licensed under the Apache License 2.0 as well. The Mac release also contains third-party
software under its own licenses (among them the arm64 Linux guest kernels and BusyBox under
GPL-2.0-only); `THIRD-PARTY.md` in the installed release lists each component, `licenses/` holds
the license texts, and the sources archive published next to each release tarball holds their
source.

## Updating the formula

At each hydo release, the hydo repository's `hydo/dist/mac/update-homebrew.sh <version> <tap
checkout>` writes the formula's `url` and `sha256` from the release's `SHA256SUMS` and checks the
published tarball against it; the change is then committed and pushed here.
