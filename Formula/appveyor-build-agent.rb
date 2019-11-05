class AppveyorBuildAgent < Formula
  desc "AppVeyor Build Agent - runs AppVeyor build on your server."
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.2546/appveyor-build-agent-7.0.2546-macos-x64.tar.gz"
  version "7.0.2546"
  sha256 "96c32bf0fb8ef055532c2036b6e7f39213102c107fe9041f40243fc5a62effc9"

  def install
    # tune config file
    unless ENV.key?("HOMEBREW_BUILD_AGENT_MODE")
      opoo "HOMEBREW_BUILD_AGENT_MODE variable not set. Will use default value 'Process'"
      ENV["HOMEBREW_BUILD_AGENT_MODE"] = "Process"
    end
    inreplace "appsettings.json", /\"Mode\": \"Process\"/, "\"Mode\": \"#{ENV["HOMEBREW_BUILD_AGENT_MODE"]}\""

    # copy all files
    cp_r ".", prefix.to_s
  end

  def caveats
    <<~EOS
      Start AppVeyor Build Agent with:

          sudo brew services start appveyor-build-agent

      AppVeyor Build Agent configuration file: #{prefix}/appsettings.json
    EOS
  end


  plist_options :startup => true

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
          <string>#{prefix}/appveyor-build-agent</string>
          <key>ProgramArguments</key>
          <array>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{prefix}</string>
          <key>StandardErrorPath</key>
          <string>#{prefix}/build-agent.stderr.log</string>
          <key>StandardOutPath</key>
          <string>#{prefix}/build-agent.stdout.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test appveyor-build-agent`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
