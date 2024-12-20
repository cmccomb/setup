#!/usr/bin/env sh

cd stubs || exit 1;

# Function to remove subsequent shebangs
remove_extra_shebangs() {
  sed -i '' '1!{/^#!/d;}' "$1"
}

# Build the play stack
cat \
  check/icloud_is_signed_in \
  check/system_preferences_is_closed \
  variables/username \
  xcode/install_developer_tools \
  homebrew/install \
  homebrew/install_base \
  homebrew/install_work \
  homebrew/cleanup \
  app_store/install_base \
  app_store/install_play \
  web_apps/base \
  web_apps/install_work \
  web_apps/cleanup \
  wallpaper/base \
  wallpaper/work \
  terminal/customize \
  textedit/customize \
  updates/customize \
  safari/customize \
  finder/customize \
  ui/customize \
  screenshots/customize \
  energy/customize \
  io/customize \
  oh_my_zsh/install \
  > ../scripts/play.zsh

# Remove subsequent shebangs from play stack
remove_extra_shebangs ../scripts/play.zsh

# Build the work stack
cat \
  check/icloud_is_signed_in \
  check/system_preferences_is_closed \
  variables/username \
  xcode/install_developer_tools \
  homebrew/install \
  homebrew/install_base \
  homebrew/install_play \
  homebrew/cleanup \
  app_store/install_base \
  app_store/install_work \
  web_apps/base \
  web_apps/install_play \
  web_apps/cleanup \
  wallpaper/base \
  wallpaper/play \
  terminal/customize \
  textedit/customize \
  updates/customize \
  safari/customize \
  finder/customize \
  ui/customize \
  screenshots/customize \
  energy/customize \
  io/customize \
  oh_my_zsh/install \
  > ../scripts/work.zsh

# Remove subsequent shebangs from work stack
remove_extra_shebangs ../scripts/work.zsh