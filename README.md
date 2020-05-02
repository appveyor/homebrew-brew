# homebrew-brew

Homebrew formulae for AppVeyor Server and AppVeyor Host Agent.

Tap Appveyor formulae repo:

    $ brew tap appveyor/brew

# Appveyor server installation

    $ brew install appveyor-server

Load and run Appveyor Server as service:

    $ sudo brew services start appveyor-server


# Host Agent Installation

    $ brew install appveyor-host-agent

User can provide Host Auth Token and CI URL in environment variables:

    $ export HOMEBREW_APPEYOR_URL=https://ci.appveyor.com
    $ export HOMEBREW_HOST_AUTH_TKN=<Host Auth Token>
    $ brew install appveyor-host-agent

Or in one line:

    $ HOMEBREW_APPEYOR_URL='https://ci.appveyor.com' HOMEBREW_HOST_AUTH_TKN='<Host Auth Token>' brew install appveyor-host-agent

Load and run Appveyor Host Agent as service:

    $ brew services start appveyor-host-agent
