#!/bin/sh
/usr/bin/osascript > /dev/null <<EOT
tell application "Finder"
    make new alias file to folder "Applications" of startup disk at disk "Heat Wizard"
end tell
EOT