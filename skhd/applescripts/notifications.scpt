activate application "NotificationCenter"
tell application "System Events"
    tell process "Notification Center"
        repeat

            try
                set theWindow to group 1 of UI element 1 of scroll area 1 of window "Notification Center"
            on error
                exit repeat
            end try

            try
                set theActions to actions of theWindow

                # Try to close the whole group first. If that fails, close individual windows.
                repeat with theAction in theActions
                    if description of theAction is "Clear All" then
                        set closed to true
                        tell theWindow
                            perform theAction
                        end tell
                        exit repeat
                    end if
                end repeat

                repeat with theAction in theActions
                    if description of theAction is "Close" then
                        set closed to true
                        tell theWindow
                            perform theAction
                        end tell
                        exit repeat
                    end if
                end repeat

            end try
        end repeat
    end tell
end tell
