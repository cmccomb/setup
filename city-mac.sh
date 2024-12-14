#!/usr/bin/env bash

###############################################################################
############################ Mise en place ####################################
###############################################################################

function __mise() {
	echo "Setting up your Mac..."
	
	# ✅ Prevent them from overriding settings we’re about to change
	osascript -e 'tell application "System Preferences" to quit'
	
	# ✅ Install xcode things
	xcode-select --install
	
	# Loop until developer tools are fully installed
	echo "Waiting for Xcode developer tools to finish installing..."
	while true; do
	    # Check if the tools are installed
	    if xcode-select -p &> /dev/null; then
	        echo "Xcode developer tools are successfully installed!"
	        break
	    else
	        echo "Developer tools are still installing. Checking again in 10 seconds..."
	        sleep 10
	    fi
	done
	
	# ✅ Install oh-my-zsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	# ✅ Save the username for later use
	USERNAME=$(id -un)	
}

__mise

###############################################################################
################### Install Applications with Homebrew ########################
###############################################################################

function __brew() {
	echo "Installing applications with Homebrew..."
	
	if test ! "$(which brew)"; then
		# ✅ Install Homebrew if not already present
		echo "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		# ✅  Add Homebrew to Path
		echo >> /Users/"$USERNAME"/.zprofile
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/work/.zprofile
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
	
	# ✅ Update Homebrew
	brew update
	brew upgrade
	
	# ✅ Install installation utilities
	brew install mas dockutil
	
	# ✅ Install utilities
	brew install wget tree htop trash
	
	# ✅ Install Docker and associated tools
	brew install docker --cask
	
	# ✅ Install code editing tools
	brew install jetbrains-toolbox pycharm webstorm rustrover --cask
	
	# ✅ Install file and project management
	brew install box-drive github
	
	# ✅ Install collaboration
	brew install microsoft-teams zoom --cask
	
	# ✅ Install LLM stuff
	brew install llama.cpp
	brew install jan --cask
	
	# ✅ Cleanup
	brew cleanup
}

 __brew

###############################################################################
################### Install Applications with App Store #######################
###############################################################################

function __mas() {

	echo "Installing applications with the App Store..."
	
	# ✅ Function to check if iCloud is signed in
	function is_icloud_signed_in() {
	  if defaults read MobileMeAccounts | grep -q AccountID; then
	    return 0
	  else
	    return 1
	  fi
	}
	
	# ✅ Function to get more info and install an app from the App Store
	function mas_info_and_install() {
	  if is_icloud_signed_in; then
	    mas info "$1"
	    mas install "$1"
	  else
	    echo "iCloud is not signed in. Skipping installation."
	  fi
	}
	
	# ✅ Function to uninstall an app only if it exists
	function check_and_uninstall() {
		if [[ -z "$1" ]]; then
			echo "Usage: uninstall_app_by_id <APP_ID>"
			return 1
		fi
		
		local app_id=$1
		
		if ! mas list | grep -q "$app_id"; then
			echo "App with ID $app_id is not installed."
			return 1
		fi
		
		echo "Uninstalling app with ID $app_id..."
		mas uninstall "$app_id" 2>/dev/null || echo "Failed to uninstall. Try removing manually."
	}
	
	# ✅ Uninstall weird Apple stuff
	if is_icloud_signed_in; then
		sudo check_and_uninstall 409183694 # Keynote
		sudo check_and_uninstall 408981434 # iMovie
		sudo check_and_uninstall 409201541 # Pages
		sudo check_and_uninstall 682658836 # GarageBand
		sudo check_and_uninstall 409203825 # Numbers
		
		# ✅ Upgrade files
		sudo mas upgrade
	fi
	
	# ✅ Install developer tools
	mas_info_and_install 497799835 # Xcode
	
	# ✅ Install document editing tools
	mas_info_and_install 462054704 # Microsoft Word
	mas_info_and_install 462058435 # Microsoft Excel
	mas_info_and_install 462062816 # Microsoft PowerPoint
	
	# ✅ Install collaboration tools
	mas_info_and_install 803453959 # Slack
	mas_info_and_install 310633997 # WhatsApp
	
	# ✅ Install utilities
	mas_info_and_install 937984704 # Amphetamine
	
	# ✅ Securely empty the trash
	trash -y -s
}

__mas

###############################################################################
################### Install Applications as PWAs ##############################
###############################################################################

function pwa() {

	echo "Installing applications as PWAs..."
	
	# ✅ Function to make a PWA
	function make_pwa {
		osascript <<EOF
    tell application "Safari"
      activate
      open location "$1" -- The URL of the website you want to make a PWA of
      delay 1.0 -- Allow time for Safari to open the page
    end tell

    tell application "System Events"
      tell process "Safari"
	click menu bar item "File" of menu bar 1 -- Open the "File" menu
	delay 0.5 -- Allow the menu to appear

	-- Select "Add to Dock…" menu item
	click menu item "Add to Dock…" of menu 1 of menu bar item "File" of menu bar 1

	-- Hit "Enter" to confirm in case a modal dialog appears
	delay 1.0 -- Allow time for the modal to appear and for the thumbnail to load
	keystroke return -- Hit "Enter" to confirm
      end tell
    end tell
EOF
	}
	
	# ✅ Install a Google Calendar PWA
	make_pwa "https://calendar.google.com/calendar/u/0/r"
	
	# ✅ Install a GMail PWA
	make_pwa "https://mail.google.com/mail/u/0/#inbox"
	
	# ✅ Make a Goole Colab PWA
	make_pwa "https://colab.new/"
	
	# ✅ Close Safari
	osascript -e 'tell application "Safari" to quit'
 }

 __pwa

###############################################################################
############################### AI Stuff ######################################
###############################################################################

function __ai_stuff() {
	echo "Installing AI stuff..."
	
	# ✅ Check if ChatGPT is already installed, and install if not
	if [ ! -d "/Applications/ChatGPT.app" ]; then
		# Download the DMG file
		curl -L -o /tmp/ChatGPT.dmg https://persistent.oaistatic.com/sidekick/public/ChatGPT.dmg
		
		# Mount the DMG file
		hdiutil attach /tmp/ChatGPT.dmg -nobrowse -quiet
		
		# Copy the app to the Applications folder
		cp -R /Volumes/ChatGPT\ Installer/ChatGPT.app /Applications/
		
		# Unmount the DMG file and clean up
		hdiutil detach /Volumes/ChatGPT -quiet
		rm /tmp/ChatGPT.dmg
	fi
	
	# ✅ Install a few of my favorite local LLMs
	llama-cli --hf-repo bartowski/Qwen2.5-0.5B-Instruct-GGUF --hf-file Qwen2.5-0.5B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-1.5B-Instruct-GGUF --hf-file Qwen2.5-1.5B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-3B-Instruct-GGUF --hf-file Qwen2.5-3B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-7B-Instruct-GGUF --hf-file Qwen2.5-7B-Instruct-Q4_K_M.gguf
}

__ai_stuff

###############################################################################
#############################  General UI/UX  #################################
###############################################################################

echo "Setting up the general UI/UX..."

# ✅ Disable the sound effects on boot
sudo nvram StartupMute=%01

# ✅ Show the battery percentage in the menubar
sudo -u "$USERNAME" defaults write /Users/"$USERNAME"/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

# ✅ Always show scrollbars (`WhenScrolling`, `Automatic` and `Always`)
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

###############################################################################
######## Trackpad, mouse, keyboard, Bluetooth accessories, and input ##########
###############################################################################

echo "Setting up trackpad, mouse, keyboard, Bluetooth accessories, and input..."

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

echo "Setting up energy saving parameters..."

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
############################### Screenshots ###################################
###############################################################################

echo "Setting up screenshot parameters..."

# ✅ Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# ✅ Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

################################################################################
################### Dock, Dashboard, and hot corners  ##########################
################################################################################

echo "Setting up the Dock, Dashboard, and hot corners..."

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


###############################################################################
################################# Finder ######################################
###############################################################################

echo "Customizing Finder..."

# ✅ Set Desktop as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# ✅ Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ✅Show hidden files by default in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ✅ Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# ✅ Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# ✅ Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

################################################################################
########################### Safari & WebKit ####################################
################################################################################
function __safari() {

	echo "Customizing Safari..."
	
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
	sudo defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true\

}

__safari


################################################################################
############################### TextEdit #######################################
################################################################################
function __textedit() {
	
	echo "Customizing TextEdit..."
	
	# ✅ Use plain text mode for new TextEdit documents
	defaults write com.apple.TextEdit RichText -int 0

}

__textedit

################################################################################
############################ Update Schedules ##################################
################################################################################
function __updates() {
		
	echo "Customizing Update Schedules"
	
	# ✅ Download automatically
	sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool TRUE
	
	# ✅ Install MacOS Updates
	sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool TRUE
	
	# ✅ Install Config Data
	sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool TRUE
	
	# ✅ Install critical updates
	sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool TRUE
	
	# ✅ Turn on app auto-update
	sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE
}

__updates

###############################################################################
############################## Photos #########################################
###############################################################################
function __photos() {
	
	echo "Customizing Photos..."
	
	# Prevent Photos from opening automatically when devices are plugged in
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

}

__photos

###############################################################################
########################## Setup The Dock #####################################
###############################################################################

function __dock() {
	
	echo "Customizing the Dock..."
	
	# ✅ Remove all dock items
	dockutil --remove all
	
	# ✅ Add back apps in the order we care about
	dockutil --add /System/Applications/System\ Settings.app --no-restart
	dockutil --add /System/Applications/Utilities/Terminal.app --no-restart
	dockutil --add /System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/ --no-restart
	dockutil --add /System/Applications/Messages.app --no-restart
	dockutil --add /Applications/Slack.app --no-restart
	dockutil --add /System/Applications/Notes.app --no-restart
	dockutil --add /System/Applications/Reminders.app --no-restart
	dockutil --add /Users/"$USER"/Applications/Calendar.app/ --no-restart
	dockutil --add /Users/"$USER"/Applications/Gmail.app/ --no-restart
	
	# ✅ Add links to desktop and Box
	dockutil --add "/" --view grid --display folder --no-restart
	dockutil --add "$HOME/Desktop" --view grid --display folder --no-restart
	dockutil --add "$HOME/Library/CloudStorage/Box-Box/" --view grid --display folder

}

__dock
