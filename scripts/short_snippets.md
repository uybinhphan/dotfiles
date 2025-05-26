# Short Snippets

---

## Note

**This is just a note to myself, not for running!**

---

## Report Total Size of Files

Report the total size of all files, including hidden ones, and directories in a human-readable format, sorted by size from largest to smallest:

```bash
du -sh $(ls -A) | sort -h
```

---

## Reset Terminal.app Settings to Default

This command resets the Terminal.app settings to their default values. It will remove all customizations, including profiles, colors, fonts, and other preferences.

**Note:** This action cannot be undone, so make sure to back up any important settings or profiles before proceeding.

```bash
tccutil reset All com.apple.Terminal
```

---

## Methods to Reset Dock Size

### 1. Reset Dock to Default Settings (including size)

Removes all customizations and restores the Dock to its original state, including size, icons, magnification, location, and other preferences.

```bash
defaults delete com.apple.dock; killall Dock
```

Effect: Fully resets the Dock and restarts it immediately.

---

### 2. Reset Only the Dock Size to Default

Keeps other Dock customizations intact while resetting only the size.

```bash
defaults delete com.apple.dock tilesize; killall Dock
```

Effect: Deletes the custom size setting and reverts the Dock icon size to the default without affecting other settings.

---

### 3. Set Dock Size to a Specific Default Value

Explicitly sets the Dock icon size to a specific value (e.g., 48 or 64 pixels).

```bash
defaults write com.apple.dock tilesize -int 48; killall Dock
```

Or for 64 pixels (common default in some versions):

```bash
defaults write com.apple.dock tilesize -int 64; killall Dock
```

Effect: Sets the Dock size directly and restarts the Dock.

---

### Alternative: Use System Settings

Adjust Dock size manually via System Settings:

1. Go to Apple menu > System Settings > Desktop & Dock
2. Use the "Size" slider to adjust Dock size visually.


## To get the bundle identifier (the "name" like com.apple.Terminal) of Visual Studio Code on macOS, you can use the Terminal with the following command:
```bash
osascript -e 'id of app "Visual Studio Code"'
```
This will output the bundle ID, which for VSCode is typically:
text
```bash
com.microsoft.VSCode
```