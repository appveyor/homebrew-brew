class AppveyorHostAgent < Formula
  desc "AppVeyor Host Agent - runs AppVeyor builds on your server."
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.3292/appveyor-host-agent-7.0.3292-macos-x64.tar.gz"
  version "7.0.3293"
  sha256 "2d671e8c97af903c58a78e3c5c8b4bce30d202138e06ad14de36e10672b04105"

  def install
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

    # copy all files
    cp_r ".", prefix.to_s
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

  service do
    run [opt_prefix/"appveyor-host-agent"]
    keep_alive true
    working_dir opt_prefix
    environment_variables PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    log_path var/"log/appveyor-host-agent.log"
    error_log_path var/"log/appveyor-host-agent.log"
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
