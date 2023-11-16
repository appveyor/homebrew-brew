class AppveyorBuildAgent < Formula
  desc "AppVeyor Build Agent - runs AppVeyor build on your server."
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.3212/appveyor-build-agent-7.0.3212-macos-x64.tar.gz"
  version "7.0.3212"
  sha256 "ca208dbf24f0e1c05206fe65f8b8b9c59c23fde132b7b902726996faf9a91973"

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


  service do
    run "#{opt_prefix}/appveyor-build-agent"
    keep_alive successful_exit: true
    environment_variables PATH: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    working_dir "#{var}/appveyor/build-agent/"
    log_path "#{var}/build-agent.stdout.log"
    error_log_path "#{var}/build-agent.stderr.log"
    run_at_load true
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
