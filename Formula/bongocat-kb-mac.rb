class BongocatKbMac < Formula
  desc "macOS menu bar Bongo Cat that reacts to your keyboard"
  homepage "https://github.com/junjiwon1031/bongocat-kb-mac"
  url "https://github.com/junjiwon1031/bongocat-kb-mac/archive/refs/tags/v0.0.2.tar.gz"
  sha256 ""
  license "MIT"

  depends_on :macos
  depends_on macos: :sonoma

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    app_name = "BongoCatNoMouse"
    app_bundle = prefix/"#{app_name}.app"

    (app_bundle/"Contents/MacOS").mkpath
    (app_bundle/"Contents/Resources").mkpath
    cp buildpath/".build/release/#{app_name}", app_bundle/"Contents/MacOS/#{app_name}"
    cp_r buildpath/".build/release/#{app_name}_#{app_name}.bundle", app_bundle/"Contents/Resources/"
    cp buildpath/"BongoCatNoMouse/Info.plist", app_bundle/"Contents/Info.plist"

    (bin/"bongocat-kb-mac").write <<~EOS
      #!/bin/bash
      APP="#{app_bundle}"
      LINK="$HOME/Applications/#{app_name}.app"
      if [ ! -L "$LINK" ]; then
        mkdir -p "$HOME/Applications"
        rm -rf "$LINK"
        ln -sf "$APP" "$LINK"
      fi
      open "$APP"
    EOS
  end

  def caveats
    <<~EOS
      Run `bongocat-kb-mac` to launch (auto-links to ~/Applications/ on first run).
      Or directly: open "#{prefix}/BongoCatNoMouse.app"

      First launch requires Accessibility permission:
        System Settings → Privacy & Security → Accessibility → enable BongoCatNoMouse
    EOS
  end
end
