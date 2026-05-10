--- === Calendar ===
---
--- A calendar inset into the desktop
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/Calendar.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/Calendar.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "Calendar"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.calw = 260
obj.calh = 184

local function updateCalCanvas()
    local titlestr = os.date("%B %Y")
    obj.canvas[2].text = titlestr
    local current_year = os.date("%Y")
    local current_month = os.date("%m")
    local current_day = os.date("%d")
    local firstday_of_nextmonth = os.time{year=current_year, month=current_month+1, day=1}
    local maxday_of_currentmonth = os.date("*t", firstday_of_nextmonth-24*60*60).day
    local weekday_of_firstday = os.date("*t", os.time{year=current_year, month=current_month, day=1}).wday
    local needed_rownum = math.ceil((weekday_of_firstday+maxday_of_currentmonth-1)/7)

    for i=1,needed_rownum do
        for k=1,7 do
            local caltable_idx = 7*(i-1)+k
            local pushbacked_value = caltable_idx-weekday_of_firstday + 2
            if pushbacked_value <= 0 or pushbacked_value > maxday_of_currentmonth then
                obj.canvas[9+caltable_idx].text = ""
            else
                obj.canvas[9+caltable_idx].text = pushbacked_value
            end
            if pushbacked_value == math.tointeger(current_day) then
                obj.canvas[58].frame.x = tostring((10+(obj.calw-20)/8*k)/obj.calw)
                obj.canvas[58].frame.y = tostring((10+(obj.calh-20)/8*(i+1))/obj.calh)
            end
        end
    end
    -- update yearweek
    local yearweek_of_firstday = hs.execute("date -v1d +'%W'")
    for i=1,6 do
        local yearweek_rowvalue = math.tointeger(yearweek_of_firstday)+i-1
        obj.canvas[51+i].text = yearweek_rowvalue
        if i > needed_rownum then
            obj.canvas[51+i].text = ""
        end
    end
    -- trim the canvas
    obj.canvas:size({
        w = obj.calw,
        h = 20+(obj.calh-20)/8*(needed_rownum+2)
    })
end

function obj:init()
    local caltodaycolor = {red=1, blue=1, green=1, alpha=0.3}
    local calcolor = {red=235/255, blue=235/255, green=235/255}
    local calbgcolor = {red=0, blue=0, green=0, alpha=0.3}
    local weeknumcolor = {red=246/255, blue=246/255, green=246/255, alpha=0.5}
    local cscreen = hs.screen.mainScreen()
    local cres = cscreen:fullFrame()

    obj.canvas = hs.canvas.new({
        x = cres.w-obj.calw-20,
        y = cres.h-obj.calh-20,
        w = obj.calw,
        h = obj.calh
    }):show()

    obj.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    obj.canvas:level(hs.canvas.windowLevels.desktopIcon)

    obj.canvas[1] = {
        id = "cal_bg",
        type = "rectangle",
        action = "fill",
        fillColor = calbgcolor,
        roundedRectRadii = {xRadius = 10, yRadius = 10},
    }

    obj.canvas[2] = {
        id = "cal_title",
        type = "text",
        text = "",
        textFont = "Courier",
        textSize = 16,
        textColor = calcolor,
        textAlignment = "center",
        frame = {
            x = tostring(10/obj.calw),
            y = tostring(10/obj.calw),
            w = tostring(1-20/obj.calw),
            h = tostring((obj.calh-20)/8/obj.calh)
        }
    }

    local weeknames = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
    for i=1,#weeknames do
        obj.canvas[2+i] = {
            id = "cal_weekday",
            type = "text",
            text = weeknames[i],
            textFont = "Courier",
            textSize = 16,
            textColor = calcolor,
            textAlignment = "center",
            frame = {
                x = tostring((10+(obj.calw-20)/8*i)/obj.calw),
                y = tostring((10+(obj.calh-20)/8)/obj.calh),
                w = tostring((obj.calw-20)/8/obj.calw),
                h = tostring((obj.calh-20)/8/obj.calh)
            }
        }
    end

    -- Create 7x6 calendar table
    for i=1,6 do
        for k=1,7 do
            obj.canvas[9+7*(i-1)+k] = {
                type = "text",
                text = "",
                textFont = "Courier",
                textSize = 16,
                textColor = calcolor,
                textAlignment = "center",
                frame = {
                    x = tostring((10+(obj.calw-20)/8*k)/obj.calw),
                    y = tostring((10+(obj.calh-20)/8*(i+1))/obj.calh),
                    w = tostring((obj.calw-20)/8/obj.calw),
                    h = tostring((obj.calh-20)/8/obj.calh)
                }
            }
        end
    end

    -- Create yearweek column
    for i=1,6 do
        obj.canvas[51+i] = {
            type = "text",
            text = "",
            textFont = "Courier",
            textSize = 16,
            textColor = weeknumcolor,
            textAlignment = "center",
            frame = {
                x = tostring(10/obj.calw),
                y = tostring((10+(obj.calh-20)/8*(i+1))/obj.calh),
                w = tostring((obj.calw-20)/8/obj.calw),
                h = tostring((obj.calh-20)/8/obj.calh)
            }
        }
    end

    -- today cover rectangle
    obj.canvas[58] = {
        type = "rectangle",
        action = "fill",
        fillColor = caltodaycolor,
        roundedRectRadii = {xRadius = 3, yRadius = 3},
        frame = {
            x = tostring((10+(obj.calw-20)/8)/obj.calw),
            y = tostring((10+(obj.calh-20)/8*2)/obj.calh),
            w = tostring((obj.calw-20)/8/obj.calw),
            h = tostring((obj.calh-20)/8/obj.calh)
        }
    }

    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(1800, function() updateCalCanvas() end)
        obj.timer:setNextTrigger(0)
    else
        obj.timer:start()
    end
end

return obj
