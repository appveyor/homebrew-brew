# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class AppveyorServerMacosX < Formula
  desc "Appveyor Server. Continuous Integration solution for Windows and Linux"
  homepage "https://www.appveyor.com"
  url "https://www.appveyor.com/downloads/appveyor-server/7.0/macos/appveyor-server-macos-x64.tar.gz"
  sha256 "30505b42a60b3a30b52fd3703a19bc7e4bd4e8bee77555cff1fdfbe6ad5a5275"

  def install
    # copy all files
    cp_r ".", prefix.to_s

    # tune config file
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    master_key = (0...16).map { o[rand(o.length)] }.join
    master_key_salt = (0...16).map { o[rand(o.length)] }.join
    inreplace "appsettings.server.linux.json", /\[HTTP_PORT\]/, "80"
    inreplace "appsettings.server.linux.json", /\[HTTPS_PORT\]/, "443"
    inreplace "appsettings.server.linux.json", /\[MASTER_KEY\]/, master_key
    inreplace "appsettings.server.linux.json", /\[MASTER_KEY_SALT\]/, master_key_salt
    #TODO rewrite with json parser
    inreplace "appsettings.server.linux.json", /\"DataDir\":.*/, "\"DataDir\": \"#{var}/opt/appveyor/server\","
    mv "appsettings.server.linux.json", "appsettings.json"
    (etc/"opt/appveyor/server").install "appsettings.json"
  end

  def post_install
    # Make sure runtime directories exist
    (var/"appveyor/server/artifacts").mkpath
  end

  def caveats; <<~EOS
      var:  #{var}
      etc:  #{etc}
      opt:  #{opt}
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
