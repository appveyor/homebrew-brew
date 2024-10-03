class AppveyorBuildAgent < Formula
  desc "AppVeyor Build Agent - runs AppVeyor build on your server."
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.3340/appveyor-build-agent-7.0.3340-macos-x64.tar.gz"
  version "7.0.3340"
  sha256 "0b45cf9a7899ea4bbed80aa7111b532734c07f560f1be337b8a30acad4169b29"

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

  def post_install
    (var/"log").mkpath
  end

  def caveats
    <<~EOS
      Start AppVeyor Build Agent with:

          sudo brew services start appveyor-build-agent

      AppVeyor Build Agent configuration file: #{opt_prefix}/appsettings.json
    EOS
  end

  service do
    run [opt_prefix/"appveyor-build-agent"]
    keep_alive true
    working_dir opt_prefix
    environment_variables PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    log_path var/"log/appveyor-build-agent.log"
    error_log_path var/"log/appveyor-build-agent.log"
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
