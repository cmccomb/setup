# Install xcode stuff
xcode-select --install

# Install Homebrew if not already present after checking with which brew
if test ! $(which brew); then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Docker and associated tools
brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve

# Install code editing tools
brew install jetbrains-toolbox pycharm webstorm rustrover

# Install document editing tools
brew install microsoft-word microsoft-excel microsoft-powerpoint

# Install file and project management
brew install box-drive github

# Install collaboration tools
brew install slack microsoft-teams zoomus