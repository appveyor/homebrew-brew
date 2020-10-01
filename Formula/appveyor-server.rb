class AppveyorServer < Formula
  desc "AppVeyor Server - Continuous Integration solution for Windows, Linux and Mac."
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.2915/appveyor-server-7.0.2915-macos-x64.tar.gz"
  version "7.0.2942"
  sha256 "09d9e890afc68c8c5865b34f686856b06bd1803b67ef03f45d1a85e091e71347"

  def install
    # copy all files
    cp_r ".", prefix.to_s

    # tune config file
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    master_key = (0...16).map { o[rand(o.length)] }.join
    master_key_salt = (0...16).map { o[rand(o.length)] }.join
    inreplace "appsettings.server.macos.json" do |appsettings|
      appsettings.gsub! /\[MASTER_KEY\]/, "#{master_key}"
      appsettings.gsub! /\[MASTER_KEY_SALT\]/, "#{master_key_salt}"
      appsettings.gsub! /\[HTTP_PORT\]/, "8050"
      appsettings.gsub! /\[HTTPS_PORT\]/, "8051"
      #TODO rewrite with json parser
      appsettings.gsub! /\"DataDir\":.*/, "\"DataDir\": \"#{var}/appveyor/server\","
    end
    mv "appsettings.server.macos.json", "appsettings.json"
    (etc/"opt/appveyor/server").install "appsettings.json"
  end

  def post_install
    # Make sure runtime directories exist
    (var/"appveyor/server/artifacts").mkpath
  end

  plist_options :startup => true

  def caveats; <<~EOS
    Start AppVeyor Server with:

        brew services start appveyor-server

    Open http://localhost:8050 in your browser to continue with AppVeyor setup.

    AppVeyor Server configuration file is #{etc}/opt/appveyor/server/appsettings.json
    Build artifacts will be stored in #{var}/appveyor/server/artifacts
  EOS
  end

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <false/>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>Program</key>
          <string>#{prefix}/appveyor-server</string>
          <key>ProgramArguments</key>
          <array>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}/appveyor/server/</string>
          <key>StandardErrorPath</key>
          <string>#{var}/appveyor/server/server.stderr.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/appveyor/server/server.stdout.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test appveyor-server-macos-x`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
