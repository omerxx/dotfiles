--- === GoMaCal ===
---
--- Google Calendar meeting notifier for Hammerspoon
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GoMaCal"
obj.version = "1.0"
obj.author = "omerxx"
obj.homepage = "https://github.com/omerxx/GoMaCal"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Internal variables
obj.timer = nil
obj.calendarPath = '/Users/omerxx/dotfiles/hammerspoon/calendar-app/calapp'

function obj:parse_event(event_string)
    if not event_string then return nil end
    local title, time_info, meeting_link = event_string:match("(.+) § (.+) § (.*)")
    if not title or not time_info then return nil end
    -- Trim any whitespace or newlines from the meeting link
    meeting_link = meeting_link and meeting_link:gsub("^%s*(.-)%s*$", "%1")
    return {
        title = title,
        time_info = time_info,
        meeting_link = (meeting_link and meeting_link ~= "") and meeting_link or nil
    }
end

function obj:check_calendar_events()
    local cmd = self.calendarPath .. ' --next 5m'
    cmd = cmd .. " 2>&1"
    local handle = io.popen(cmd)
    local Result
    if handle then
        Result = handle:read("*a") -- reads all output
        handle:close()
    end

    local event = self:parse_event(Result)
    if not event then return end

    hs.alert.defaultStyle = {
        strokeWidth  = 2,
        strokeColor = { red = 1, alpha = 1 },
        fillColor   = { white = 0, alpha = 0.75 },
        textColor = { white = 1, alpha = 1 },
        textFont  = ".AppleSystemUIFont",
        textSize  = 67,
        radius = 27,
        atScreenEdge = 0,
        fadeInDuration = 0.15,
        fadeOutDuration = 0.15,
        padding = nil,
    }
    print(event.title)

    hs.notify.new(function(n)
        if event.meeting_link then
            hs.urlevent.openURL(event.meeting_link)
        end
    end)
        :subTitle(event.time_info)
        :title(event.title)
        :autoWithdraw(false)
        :alwaysPresent(true)
        :withdrawAfter(0)
        :hasActionButton(true)
        :actionButtonTitle("go to meeting")
        :send()
end

--- GoMaCal:start()
--- Method
--- Starts the calendar checker timer
---
--- Parameters:
---  * None
---
--- Returns:
---  * The GoMaCal object
function obj:start()
    self:stop()
    self.timer = hs.timer.doEvery(60, function() self:check_calendar_events() end)
    return self
end

--- GoMaCal:stop()
--- Method
--- Stops the calendar checker timer
---
--- Parameters:
---  * None
---
--- Returns:
---  * The GoMaCal object
function obj:stop()
    if self.timer then
        self.timer:stop()
        self.timer = nil
    end
    return self
end

--- GoMaCal:setCalendarPath(path)
--- Method
--- Sets the path to the calendar binary
---
--- Parameters:
---  * path - String containing the full path to the calendar binary
---
--- Returns:
---  * The GoMaCal object
function obj:setCalendarPath(path)
    self.calendarPath = path
    return self
end

return obj
