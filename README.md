# Windows-11-remove-unwanted-features

This project provides a lightweight batch script to make Windows 11 feel more like Windows 7 or 10, without aggressive debloating. The script applies safe tweaks such as:

* Remove Bing and Microsoft Store search results from the Start menu
* Remove taskbar Search icon
* Restore the full (classic) right-click context menu
* Show file extensions for all files
* Disable Widgets (taskbar toggle and policy)
* Disable lock screen news/tips and Windows Spotlight content
* Remove Task View (desktop switch) button
* Remove Taskbar Chat
* Enable End Task option on taskbar app right-click
* Move the taskbar to the left (classic position)
* Show all system tray icons

**Note:** A restart may be required for changes to take effect.

## Customization

Each tweak in the script can be commented or uncommented depending on your requirements. Simply open `remove_unwanted_features.bat` in a text editor and add or remove `::` at the beginning of lines to enable or disable specific features.

No aggressive debloating or removal of core Windows features is performed. The script is intended to provide a familiar, classic Windows experience with minimal risk.

## Reverting to Default Windows 11 Features

If you want to restore all features back to the default Windows 11 experience, use the `restore_default_features.bat` script included in this repository. This script will revert all changes made by `remove_unwanted_features.bat`, including PowerShell execution policy, context menus, taskbar settings, widgets (including policy values), lock screen Spotlight/news content, file extensions, and more. It is safe to run even if some settings are already at their default values.