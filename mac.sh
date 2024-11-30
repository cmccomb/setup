#!/usr/bin/env bash

###############################################################################
############################ Mise en place ####################################
###############################################################################

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
########################### Update Xcode Stuff ################################
###############################################################################

# Install xcode things
sudo xcodebuild -license
xcode-select --install

###############################################################################
################### Install Applications with Homebrew ########################
###############################################################################

# Install Homebrew if not already present
if test ! $(which brew); then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
brew update
brew upgrade

# Install utilities
brew install wget tree htop trash

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

# Cleanup
brew cleanup

###############################################################################
########################## Setup The Dock #####################################
###############################################################################

# Setup the dock
brew install dockutil

# Remove all dock items
dockutil --remove all

# Add back stuff in the order we care about
dockutil --add /Applications/System\ Settings.app --no-restart
dockutil --add /Applications/Utilities/Terminal.app --no-restart
dockutil --add /Applications/Safari.app --no-restart
dockutil --add /Applications/Messages.app --no-restart
dockutil --add /Applications/Slack.app --no-restart
dockutil --add /Applications/Notes.app --no-restart
dockutil --add /Applications/Reminders.app --no-restart
dockutil --add /Users/mccomb/Applications/Calendar.app/ --no-restart # TODO: Make the PWA
dockutil --add /Users/mccomb/Applications/Gmail.app/ # TODO: Make the PWA


###############################################################################
#############################  General UI/UX  #################################
###############################################################################

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

########################################################
##################### Aesthetics #######################
########################################################
