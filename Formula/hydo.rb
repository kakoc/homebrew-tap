# hydo for Apple Silicon Macs, from the prebuilt Mac release on GitHub.
#
# The release is installed as it is into the keg's libexec (the same tree as ~/.hydo of the
# release's install.sh), and bin/ gets symlinks to its user-facing programs. hydo finds its
# release files from its own path with symlinks resolved, so the links work. Homebrew neither
# cleans nor relocates libexec (no permission changes, no install-name changes, no re-signing of
# the programs, which link only system libraries), so every file still matches the release's
# SHA256SUMS when the post-install step runs `hydo setup`. That step checks every file against
# SHA256SUMS and the sha256 pins built into hydo, and signs bin/hydo-hvm (the virtual-machine
# engine) on this Mac with the hypervisor entitlement. The url and sha256 below are written by the hydo
# repository's hydo/dist/mac/update-homebrew.sh from the release's SHA256SUMS.
class Hydo < Formula
  desc "Deterministic fault testing of whole systems in a reproducible virtual machine"
  homepage "https://github.com/kakoc/hydo"
  url "https://github.com/kakoc/hydo/releases/download/v0.1.0/hydo-mac-0.1.0.tar.gz"
  sha256 "5c02e7f364424e97aad67a7fa91b73d29a8466e5fe17ea4bd540edc06dac9806"
  # hydo's own code. hydo's Linux kernel module (GPL-2.0-only) is in the Linux release only and
  # not in this tarball. The tarball also carries third-party software under its own licenses,
  # among them the arm64 Linux guest kernels and BusyBox (GPL-2.0-only); THIRD-PARTY.md and
  # licenses/ in libexec list each one, and hydo-mac-<version>-sources.tar.gz next to the release
  # tarball holds their source.
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    libexec.install Dir["*"]
    # A copy of the license in the keg's top directory. Without one, Homebrew would move the
    # release's own LICENSE out of libexec, and `hydo setup` would then find the release
    # incomplete (SHA256SUMS lists the file).
    cp libexec/"LICENSE", prefix
    # hydo is the command; hydo-build (the image builder's own command line, for scripts) and
    # hydo-fetch-image (which the fetch-images.sh of `hydo compose` looks for on PATH) are
    # linked too. bin/hydo-hvm is the engine hydo starts from libexec; it is not linked.
    %w[hydo hydo-build hydo-fetch-image].each do |program|
      bin.install_symlink libexec/"bin"/program
    end
  end

  post_install_steps do
    run "bin/hydo", base: :libexec, args: ["setup"]
  end

  def caveats
    <<~EOS
      hydo setup ran after the installation: it checked every file and signed the engine
      #{opt_libexec}/bin/hydo-hvm with the hypervisor entitlement.
      If it did not complete, run it again:
        hydo setup
      Then check this Mac and the installation:
        hydo doctor
      The quickstart and the bundled examples are in #{opt_libexec}:
        #{opt_libexec}/QUICKSTART-mac.md
        cp -R #{opt_libexec}/examples/redis ~/hydo-redis
    EOS
  end

  test do
    assert_match "hydo #{version}, the Mac release", shell_output("#{bin}/hydo setup --check")
    assert_match "doctor: all checks passed", shell_output("#{bin}/hydo doctor")
    cp_r libexec/"examples/redis", testpath
    cd testpath/"redis" do
      system bin/"hydo", "build", "hydo.yaml", "--check"
    end
  end
end
