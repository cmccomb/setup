########################################################
################## Update Xcode Stuff ##################
########################################################

# Install xcode things
sudo xcodebuild -license
xcode-select --install

########################################################
########## Install Applications with Homebrew ##########
########################################################

# Install Homebrew if not already present
if test ! $(which brew); then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
brew update
brew upgrade

# Install Docker and associated tools
brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve

# Install code editing tools
brew install jetbrains-toolbox pycharm webstorm rustrover

# Install document editing tools
brew install microsoft-word microsoft-excel microsoft-powerpoint

# Install file and project management
brew install box-drive github

# Install collaboration tools
brew install slack microsoft-teams zoomus whatsapp

# Setup the dock
brew install dockutil

# Cleanup
brew cleanup

########################################################
################# Setup The Dock #######################
########################################################

# Remove all dock items
dockutil --remove all

# Add back stuff in the order we care about
dockutil --add /Applications/System\ Settings.app --no-restart
dockutil --add /Applications/Utilities/Terminal.app --no-restart
dockutil --add /Applications/Safari.app --no-restart
dockutil --add /Applications/Messages.app --no-restart
dockutil --add /Applications/Slack.app --no-restart
dockutil --add /Applications/Notes.app --no-restart
dockutil --add /Applications/Reminders.app
dockutil --add /Users/mccomb/Applications/Calendar.app/
dockutil --add /Users/mccomb/Applications/Gmail.app/

########################################################
################# Setup The Finder #####################
########################################################

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true