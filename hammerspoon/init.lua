hs = hs
hs.loadSpoon("AClock")

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

local calendar = hs.loadSpoon("GoMaCal")
if calendar then
    calendar:setCalendarPath('/Users/omerxx/dotfiles/hammerspoon/calendar-app/calapp')
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
--     calendar:setCalendarPath('/Users/omerxx/dotfiles/hammerspoon/calendar-app/calapp')
--     calendar:start()
-- end
