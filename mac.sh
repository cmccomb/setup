#!/usr/bin/env bash

###############################################################################
############################ Mise en place ####################################
###############################################################################

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Install xcode things
xcode-select --install

###############################################################################
################### Install Applications with Homebrew ########################
###############################################################################

# Install Homebrew if not already present
if test ! "$(which brew)"; then
	echo "Installing Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
brew update
brew upgrade

# Install installation utilities
brew install mas dockutil

# Install utilities
brew install wget tree htop trash

# Install Docker and associated tools
brew install docker --cask

# Install code editing tools
brew install jetbrains-toolbox pycharm webstorm rustrover --cask

# Install file and project management
brew install box-drive github

# Install collaboration tools
brew install microsoft-teams zoom --cask

# Install LLM stuff
brew install llama.cpp
brew install jan --cask

# Cleanup
brew cleanup

###############################################################################
################### Install Applications with App Store #######################
###############################################################################

# Install developer tools
mas install 497799835 # Xcode

# Install document editing tools
mas install 462054704 # Microsoft Word
mas install 462058435 # Microsoft Excel
mas install 462062816 # Microsoft PowerPoint

# Install collaboration tools
mas install 803453959 # Slack
mas install 310633997 # WhatsApp

# Install utilities
mas install 937984704 # Amphetamine

###############################################################################
################### Install Applications as PWAs ##############################
###############################################################################

function make_pwa {
	osascript <<EOF
    tell application "Safari"
      activate
      open location "$1"
      delay 1.0
    end tell

    tell application "System Events"
      tell process "Safari"
        -- Open the "File" menu
        click menu bar item "File" of menu bar 1
        delay 0.5 -- Allow the menu to appear

        -- Select "Add to Dock…" menu item
        click menu item "Add to Dock…" of menu 1 of menu bar item "File" of menu bar 1

        -- Simulate hitting "Enter" to confirm in case a modal dialog appears
        delay 1.0 -- Allow time for the modal to appear and for the thumbnail to load
        keystroke return
      end tell
    end tell
EOF
}

make_pwa "https://calendar.google.com/calendar/u/0/r"
make_pwa "https://mail.google.com/mail/u/0/#inbox"
osascript -e 'tell application "Safari" to quit'

###############################################################################
############################## LLM Stuff ######################################
###############################################################################

# Download the DMG file
curl -L -o /tmp/ChatGPT.dmg https://persistent.oaistatic.com/sidekick/public/ChatGPT.dmg

# Mount the DMG file
hdiutil attach /tmp/ChatGPT.dmg -nobrowse -quiet

# Copy the app to the Applications folder
cp -R /Volumes/ChatGPT\ Installer/ChatGPT.app /Applications/

# Unmount the DMG file and clean up
hdiutil detach /Volumes/ChatGPT -quiet
rm /tmp/ChatGPT.dmg

# Install a few of my favorite local LLMs
llama-cli --hf-repo bartowski/Qwen2.5-0.5B-Instruct-GGUF --hf-file Qwen2.5-0.5B-Instruct-Q4_K_M.gguf
llama-cli --hf-repo bartowski/Qwen2.5-1.5B-Instruct-GGUF --hf-file Qwen2.5-1.5B-Instruct-Q4_K_M.gguf
llama-cli --hf-repo bartowski/Qwen2.5-3B-Instruct-GGUF --hf-file Qwen2.5-3B-Instruct-Q4_K_M.gguf
llama-cli --hf-repo bartowski/Qwen2.5-7B-Instruct-GGUF --hf-file Qwen2.5-7B-Instruct-Q4_K_M.gguf

###############################################################################
#############################  General UI/UX  #################################
###############################################################################

# Disable the sound effects on boot
sudo nvram StartupMute=%01

# Disable transparency in the menu bar and elsewhere on Yosemite
sudo defaults write com.apple.universalaccess reduceTransparency -bool true

# Show the battery percentage in the menubar.
USERNAME=$(who | grep console | awk '{ print $1 }')
sudo -u "$USERNAME" defaults write /Users/"$USERNAME"/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

# Always show scrollbars (`WhenScrolling`, `Automatic` and `Always`)
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Adjust toolbar title rollover delay
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

###############################################################################
######## Trackpad, mouse, keyboard, Bluetooth accessories, and input ##########
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false

# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

###############################################################################
############################# Energy Saving ###################################
###############################################################################

# Disable machine sleep while charging
sudo pmset -c displaysleep 60
sudo pmset -c sleep 0

# Set sleep when on battery
sudo pmset -b displaysleep 10
sudo pmset -b sleep 60

# Enable lid wakeup
sudo pmset -a lidwake 1

# Restart automatically on power loss
sudo pmset -a autorestart 1

# Set standby delay to 24 hours (default is 1 hour)
sudo pmset -a standbydelay 86400

###############################################################################
################################ Screen #######################################
###############################################################################

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

###############################################################################
################################# Finder ######################################
###############################################################################

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

################################################################################
################### Dock, Dashboard, and hot corners  ##########################
################################################################################

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 60

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

## Hot corners
## Possible values:
##  0: no-op
##  2: Mission Control
##  3: Show application windows
##  4: Desktop
##  5: Start screen saver
##  6: Disable screen saver
##  7: Dashboard
## 10: Put display to sleep
## 11: Launchpad
## 12: Notification Center
## 13: Lock Screen

# Top left screen corner
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top right screen corner
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom left screen corner
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom right screen corner
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

################################################################################
########################### Safari & WebKit ####################################
################################################################################

# Privacy: don’t send search queries to Apple
sudo defaults write com.apple.Safari UniversalSearchEnabled -bool false
sudo defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
sudo defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Hide Safari’s bookmarks bar by default
sudo defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari’s sidebar in Top Sites
sudo defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Enable Safari’s debug menu
sudo defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
sudo defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable the Develop menu and the Web Inspector in Safari
sudo defaults write com.apple.Safari IncludeDevelopMenu -bool true
sudo defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking
sudo defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
sudo defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Warn about fraudulent websites
sudo defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable Java
sudo defaults write com.apple.Safari WebKitJavaEnabled -bool false
sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

# Block pop-up windows
sudo defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
sudo defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Enable “Do Not Track”
sudo defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
sudo defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

################################################################################
################################ Spotlight #####################################
################################################################################

# Change indexing order and disable some search results
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 1;"name" = "DOCUMENTS";}' \
	'{"enabled" = 1;"name" = "IMAGES";}' \
	'{"enabled" = 1;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 1;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 0;"name" = "FONTS";}' \
	'{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 0;"name" = "CONTACT";}' \
	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "SOURCE";}'

# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1

# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null

################################################################################
############################### TextEdit #######################################
################################################################################

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

################################################################################
############################### App Store ######################################
################################################################################

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
############################## Photos #########################################
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
########################## Setup The Dock #####################################
###############################################################################

# Remove all dock items
dockutil --remove all

# Add back apps in the order we care about
dockutil --add /System/Applications/System\ Settings.app --no-restart
dockutil --add /System/Applications/Utilities/Terminal.app --no-restart
dockutil --add /System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/ --no-restart
dockutil --add /System/Applications/Messages.app --no-restart
dockutil --add /Applications/Slack.app --no-restart
dockutil --add /System/Applications/Notes.app --no-restart
dockutil --add /System/Applications/Reminders.app --no-restart
dockutil --add /Users/mccomb/Applications/Calendar.app/ --no-restart # TODO: Make the PWA programmatically
dockutil --add /Users/mccomb/Applications/Gmail.app/ --no-restart # TODO: Make the PWA programmatically

# Add links to desktop and Box
dockutil --add "$HOME/Desktop" --view grid --display folder --no-restart
dockutil --add "$HOME/Library/CloudStorage/Box-Box/" --view grid --display folder
