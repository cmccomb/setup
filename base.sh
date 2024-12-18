#!/usr/bin/env zsh

###############################################################################
############################ Mise en place ####################################
###############################################################################

function __mise_en_place() {

	echo "Je fais la mise en place..."

	# ✅ Prevent them from overriding settings we’re about to change
	osascript -e 'tell application "System Preferences" to quit'

	# ✅ Install xcode things
	xcode-select --install

	# ✅ Loop until developer tools are fully installed
	echo "Waiting for Xcode developer tools to finish installing..."
	while true; do
		# Check if the tools are installed
		if xcode-select -p &>/dev/null; then
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

###############################################################################
################### Install Applications with Homebrew ########################
###############################################################################

function __install_brew() {

	echo "Installing Homebrew..."

  # ✅ Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # ✅ Add Homebrew to Path
  echo >>/Users/"$USERNAME"/.zprofile
  echo "eval '$(/opt/homebrew/bin/brew shellenv)'" >>/Users/work/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"

	# ✅ Update Homebrew
	brew update
	brew upgrade
}

function __install_brew_base() {

	echo "Installing applications with Homebrew..."

	# ✅ Install Homebrew if needed
	__install_brew

	# ✅ Install installation and configuration utilities
	brew install mas dockutil

	# ✅ Install utilities
	brew install coreutils wget tree htop trash

}

function __install_brew_work() {

	# ✅ Install Homebrew if needed as well as base tools
	__install_brew_base

	# ✅ Install Docker and associated tools
	brew install --cask docker

	# ✅ Install code editing tools
	brew install --cask jetbrains-toolbox pycharm webstorm rustrover

	# ✅ Install file and project management
	brew install --cask box-drive github

	# ✅ Install collaboration
	brew install --cask microsoft-teams zoom

	# ✅ Cleanup
	brew cleanup

}

function __install_brew_personal() {

	# ✅ Install Homebrew if needed as well as base tools
	__install_brew_base

	# ✅ Install EVE Launcher
	brew install --cask eve-launcher

	# ✅ Install League of Legends
	brew install --cask league-of-legends

	# ✅ Cleanup
	brew cleanup

}

###############################################################################
################### Install Applications with App Store #######################
###############################################################################

# ✅ Function to check if iCloud is signed in
function __is_icloud_signed_in() {
	if defaults read MobileMeAccounts | grep -q AccountID; then
		return 0
	else
		return 1
	fi
}

# ✅ Function to get more info and install an app from the App Store
function __mas_info_and_install() {
	if __is_icloud_signed_in; then
		mas info "$1"
		mas install "$1"
	else
		echo "iCloud is not signed in. Skipping installation."
	fi
}

# ✅ Function to uninstall an app only if it exists
function __check_and_uninstall() {
	if __is_icloud_signed_in; then

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
	else
		echo "iCloud is not signed in. Skipping uninstall."
	fi

}

function __install_mas_core() {

	echo "Installing applications with the App Store..."

	# ✅ Uninstall weird Apple stuff
	if __is_icloud_signed_in; then
		__check_and_uninstall 409183694 # Keynote
		__check_and_uninstall 408981434 # iMovie
		__check_and_uninstall 409201541 # Pages
		__check_and_uninstall 682658836 # GarageBand
		__check_and_uninstall 409203825 # Numbers

		# ✅ Upgrade files
		sudo mas upgrade
	fi

	# ✅ Install collaboration tools
	__mas_info_and_install 310633997 # WhatsApp

	# ✅ Install utilities
	__mas_info_and_install 937984704 # Amphetamine

	# ✅ Install document editing tools
	__mas_info_and_install 462054704 # Microsoft Word
	__mas_info_and_install 462058435 # Microsoft Excel
	__mas_info_and_install 462062816 # Microsoft PowerPoint

	# ✅ Securely empty the trash
	trash -y -s
}

function __install_mas_work() {

	__install_mas_core

	# ✅ Install developer tools
	__mas_info_and_install 497799835 # Xcode
	sudo xcodebuild -license accept

	# ✅ Install collaboration tools
	__mas_info_and_install 803453959 # Slack

	# ✅ Securely empty the trash
	trash -y -s
}

function __install_mas_personal() {

	__install_mas_core

	# ✅ Securely empty the trash
	trash -y -s
}

###############################################################################
################### Install Applications as PWAs ##############################
###############################################################################

# ✅ Function to make a PWA
function __make_pwa {
  osascript <<EOF
  tell application "Safari"
    activate
    open location "$1" -- The URL of the website you want to make a PWA of
  end tell
EOF

  # Wait for user to press enter
  echo "Press [Enter] to continue once you have logged in..."
  read -r

  osascript <<EOF
  tell application "Safari"
    activate
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

function __install_pwa_core() {

	echo "Installing applications as PWAs..."

  # Wait for user to press enter
  echo  "For each PWA, ensure that the webpage is logged in. Then press [Enter] to continue. If you are ready, press [Enter] now."
  read -r

	# ✅ Install a GMail PWA
	__make_pwa "https://mail.google.com/mail/u/0/#inbox"

}

function __install_pwa_work() {

	__install_pwa_core

	# ✅ Install a Google Calendar PWA
	__make_pwa "https://calendar.google.com/calendar/u/0/r"

	# ✅ Make a Goole Colab PWA
	__make_pwa "https://colab.new/"

	# ✅ Close Safari
	osascript -e 'tell application "Safari" to quit'
}

function install_pwa_personal() {

	__install_pwa_core

	# ✅ Close Safari
	osascript -e 'tell application "Safari" to quit'
}

###############################################################################
########################## Setup The Dock #####################################
###############################################################################

function __set_work_dock() {

	echo "Customizing the Dock..."

	# ✅ Remove all dock items
	dockutil --remove all

	# ✅ Add links to desktop and Box
	dockutil --add "/" --view grid --display folder --no-restart
	dockutil --add "$HOME/Desktop" --view grid --display folder --no-restart
	dockutil --add "$HOME/Library/CloudStorage/Box-Box/" --view grid --display folder --no-restart

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
	dockutil --add /Users/"$USER"/Applications/Google\ Colab.app/

}

function __set_personal_dock() {

	echo "Customizing the Dock..."

	# ✅ Remove all dock items
	dockutil --remove all --no-restart

	# ✅ Add links to desktop and Box
	dockutil --add "/" --view grid --display folder --no-restart
	dockutil --add "$HOME/Desktop" --view grid --display folder --no-restart

	# ✅ Add back apps in the order we care about
	dockutil --add /System/Applications/System\ Settings.app --no-restart
	dockutil --add /System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/ --no-restart
	dockutil --add /System/Applications/Messages.app --no-restart
	dockutil --add /Users/"$USER"/Applications/Gmail.app/

}

###############################################################################
############################### AI Stuff ######################################
###############################################################################

function __install_ai_stack_core() {

	echo "Installing AI stack..."

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

	# ✅ Install Jan
	brew install --cask jan

	# ✅ Install llama-cpp
	brew install llama.cpp

}

function __install_ai_stack_personal() {

	__install_ai_stack_core

	# ✅ Install a few of my favorite local LLMs
	llama-cli --hf-repo bartowski/Qwen2.5-0.5B-Instruct-GGUF --hf-file Qwen2.5-0.5B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-1.5B-Instruct-GGUF --hf-file Qwen2.5-1.5B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-3B-Instruct-GGUF --hf-file Qwen2.5-3B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-7B-Instruct-GGUF --hf-file Qwen2.5-7B-Instruct-Q4_K_M.gguf

	#

}

function __install_ai_stack_work() {

	__install_ai_stack_core

	# ✅ Install a few of my favorite local LLMs
	llama-cli --hf-repo bartowski/Qwen2.5-1.5B-Instruct-GGUF --hf-file Qwen2.5-1.5B-Instruct-Q4_K_M.gguf
	llama-cli --hf-repo bartowski/Qwen2.5-7B-Instruct-GGUF --hf-file Qwen2.5-7B-Instruct-Q4_K_M.gguf

}

###############################################################################
#############################  General UI/UX  #################################
###############################################################################

function __general_uiux() {

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

}

###############################################################################
######## Trackpad, mouse, keyboard, Bluetooth accessories, and input ##########
###############################################################################

function __general_io() {

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

}

###############################################################################
############################# Energy Saving ###################################
###############################################################################

function __energy() {

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

}

###############################################################################
############################### Screenshots ###################################
###############################################################################

function __screenshots() {

	echo "Setting screenshot parameters..."

	# ✅ Save screenshots to the desktop
	defaults write com.apple.screencapture location -string "${HOME}/Desktop"

	# ✅ Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
	defaults write com.apple.screencapture type -string "png"

}

################################################################################
################### Dock, Dashboard, and hot corners  ##########################
################################################################################

function __more_ui() {

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

}

################################################################################
############################# Wallpaper ########################################
################################################################################

function __set_wallpaper() {
  if [[ -z "$1" ]]; then
    echo "Usage: __set_wallpaper <absolute_path_to_image>"
    return 1
  fi

  local path="$1"

  # Ensure the file exists
  if [[ ! -f "$path" ]]; then
    echo "Error: File not found at '$path'"
    return 1
  fi

  echo "Setting wallpaper to: $path"

  # Run the osascript command with Finder
  osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${path}\""

}

function __set_work_wallpaper() {

	echo "Customizing Wallpaper..."

	# Get the wallpaper
	wget "https://unsplash.com/photos/NFs6dRTBgaM/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8M3x8Z2VvbWV0cmljfGVufDB8MHx8fDE3MzQzODMyMDZ8MA" -O "/tmp/wallpaper-work.jpg"

	# Set the wallpaper
	__set_wallpaper "/tmp/wallpaper-work.jpg"

}

function __set_personal_wallpaper() {

	echo "Customizing Wallpaper..."

	# Get the wallpaper
	wget "https://unsplash.com/photos/buymYm3RQ3U/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8MjB8fG5lb24lMjBzaWduJTIwd2FsbHBhcGVyfGVufDB8MHx8fDE3MzQyMzU4MDl8Mg" -O /tmp/wallpaper-personal.png

	# Set the wallpaper
	__set_wallpaper /tmp/wallpaper-personal.png

}

###############################################################################
################################# Finder ######################################
###############################################################################

function __finder() {

	echo "Customizing Finder..."

	# ✅ Set Desktop as the default location for new Finder windows
	defaults write com.apple.finder NewWindowTarget -string "PfDe"
	defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

	# ✅ Use list view by default
	defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

	# ✅Show hidden files by default in Finder
	defaults write com.apple.finder AppleShowAllFiles -bool true

	# ✅ Make iCloud load desktop files
	defaults write com.apple.finder ShowSidebar -bool true
	defaults write com.apple.finder SidebarShowingiCloudDesktop -bool true
	defaults write com.apple.finder FXICloudDriveDesktop -bool true
	defaults write com.apple.finder FXICloudDriveDocuments -bool true

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

}

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
	sudo defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true
}

################################################################################
############################### TextEdit #######################################
################################################################################
function __textedit() {

	echo "Customizing TextEdit..."

	# ✅ Use plain text mode for new TextEdit documents
	defaults write com.apple.TextEdit RichText -int 0

}

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

###############################################################################
############################## Photos #########################################
###############################################################################
function __photos() {

	echo "Customizing Photos..."

	# Prevent Photos from opening automatically when devices are plugged in
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

}

###############################################################################
############################## Terminal #######################################
###############################################################################
function __terminal() {

	echo "Customizing Terminal..."

	# ✅ Make a new settings file
	defaults write com.apple.Terminal "Window Settings" -dict-add "Chris" '
	{
	    CommandString = "";
	    FontAntialias = 1;
	    FontWidthSpacing = "1.004032258064516";
	    ProfileCurrentVersion = "2.07";
	    RunCommandAsShell = 1;
	    name = Chris;
	    shellExitAction = 0;
	    type = "Window Settings";
	}'

	# ✅ Make the Chris profile the default
	defaults write com.apple.Terminal "Default Window Settings" "Chris"

}

###############################################################################
################## Take care of stuff that is the same ########################
###############################################################################

function __take_care_of_general_stuff() {
	__general_uiux
	__general_io
	__energy
	__screenshots
	__more_ui
	__finder
	__safari
	__textedit
	__updates
	__photos
	__terminal
}
