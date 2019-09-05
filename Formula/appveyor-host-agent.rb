class AppveyorHostAgent < Formula
  desc "AppVeyor Host Agent - runs AppVeyor builds on your server."
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.2375/appveyor-host-agent-7.0.2375-macos-x64.tar.gz"
  version "7.0.2375"
  sha256 "47d2b05f3a972dac79a253824ee867be07f89fc9718dd8c4fa42f2207f5d3286"

  def install
    # copy all files
    cp_r ".", prefix.to_s

    # tune config file
    unless ENV.key?("HOMEBREW_APPVEYOR_URL")
      opoo "HOMEBREW_APPVEYOR_URL variable not set. Will use default value 'https://ci.appveyor.com'"
      ENV["HOMEBREW_APPVEYOR_URL"] = "https://ci.appveyor.com"
    end
    inreplace "appsettings.json" do |appsettings|
      appsettings.gsub! /\[APPVEYOR_URL\]/, ENV["HOMEBREW_APPVEYOR_URL"]
      appsettings.gsub! /\"DataDir\":.*/, "\"DataDir\": \"#{var}/appveyor/host-agent\","
    end

    if ENV.key?("HOMEBREW_HOST_AUTH_TKN")
      inreplace "appsettings.json", /\[AUTHORIZATION_TOKEN\]/, ENV["HOMEBREW_HOST_AUTH_TKN"]
    end
    (etc/"opt/appveyor/host-agent").install "appsettings.json"
    rm "#{prefix}/appsettings.json"
  end

  def post_install
    # Make sure runtime directories exist
    (var/"appveyor/host-agent").mkpath
  end

  def no_token_caveat; <<~EOS_TKN
    Edit #{etc}/opt/appveyor/host-agent/appsettings.json:
      replace HOST_AUTH_TOKEN with correct Host Auth Token.
  EOS_TKN
  end

  def caveats
    <<~EOS
      Start AppVeyor Host Agent with:

          brew services start appveyor-host-agent

      AppVeyor Host Agent configuration file: #{etc}/opt/appveyor/host-agent/appsettings.json
      Database will be stored in #{var}/appveyor/host-agent/
    EOS
    no_token_caveat unless ENV.key?("HOMEBREW_HOST_AUTH_TKN")
  end


  plist_options :startup => false

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
          <string>#{prefix}/appveyor-host-agent</string>
          <key>ProgramArguments</key>
          <array>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}/appveyor/host-agent/</string>
          <key>StandardErrorPath</key>
          <string>#{var}/appveyor/host-agent/host-agent.stderr.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/appveyor/host-agent/host-agent.stdout.log</string>
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
