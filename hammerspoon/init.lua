hs = hs
hs.loadSpoon("AClock")

-- Clipboard cleaner: removes unwanted line breaks from wrapped terminal text
-- Preserves intentional paragraph breaks (double newlines)
local lastClipboard = ""
local clipboardWatcher = hs.timer.doEvery(0.5, function()
    local current = hs.pasteboard.getContents()
    if current and current ~= lastClipboard then
        lastClipboard = current
        -- Only process if it has newlines but no double-newlines (paragraph breaks)
        if current:match("\n") and not current:match("\n\n") then
            -- Replace single newlines with spaces, collapse multiple spaces
            local cleaned = current:gsub("\n", " "):gsub("  +", " "):gsub("^ ", ""):gsub(" $", "")
            if cleaned ~= current then
                hs.pasteboard.setContents(cleaned)
                lastClipboard = cleaned
            end
        end
    end
end)

hs.hotkey.bind({"cmd", "alt"}, "C", function()
  spoon.AClock:toggleShow()
end)


-- hammerspoon can be your next app launcher!!!!
hs.hotkey.bind({"cmd", "alt"}, "A", function()
	hs.application.launchOrFocus("Arc")
	-- local arc = hs.appfinder.appFromName("Arc")
	-- arc:selectMenuItem({"Help", "Getting Started"})
end)

hs.hotkey.bind({"alt"}, "R", function()
	hs.reload()
end)
hs.alert.show("Config loaded")

-- Chrome: Cmd+Shift+C to copy current URL (Cmd+L then Cmd+C)
hs.hotkey.bind({"cmd", "shift"}, "C", function()
    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == "com.google.Chrome" then
        hs.eventtap.keyStroke({"cmd"}, "L")
        hs.timer.doAfter(0.05, function()
            hs.eventtap.keyStroke({"cmd"}, "C")
        end)
    end
end)

local calendar = hs.loadSpoon("GoMaCal")
if calendar then
    calendar:setCalendarPath('/Users/klaudioz/dotfiles/hammerspoon/calendar-app/calapp')
    calendar:start()
end
























-- local function showNotification(title, message)
--     hs.notify.show(title, "", message)
-- end
--
-- hs.hotkey.bind({"cmd", "alt"}, "P", function()
--   hs.alert(hs.brightness.get())
--   showNotification("Hello", "This is a test notification")
-- end)
--
-- hs.hotkey.bind({"alt"}, "R", function()
--   hs.reload()
-- end)
-- hs.alert.show("Config loaded")
--
--
-- local function start_quicktime_movie()
--   hs.application.launchOrFocus("QuickTime Player")
--   local qt = hs.appfinder.appFromName("QuickTime Player")
--   qt:selectMenuItem({"File", "New Movie Recording"})
-- end
-- local function start_quicktime_screen()
--   hs.application.launchOrFocus("QuickTime Player")
--   local qt = hs.appfinder.appFromName("QuickTime Player")
--   qt:selectMenuItem({"File", "New Screen Recording"})
-- end
--
-- hs.hotkey.bind({"cmd", "alt"}, "m", start_quicktime_movie)
-- hs.hotkey.bind({"cmd", "alt"}, "s", start_quicktime_screen)
--
-- local calendar = hs.loadSpoon("GoMaCal")
-- if calendar then
--     calendar:setCalendarPath('/Users/klaudioz/dotfiles/hammerspoon/calendar-app/calapp')
--     calendar:start()
-- end
