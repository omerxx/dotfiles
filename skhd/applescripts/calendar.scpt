set d to current date

tell application "Calendar"
   set {startDates, summaries, UIDs} to {start date, summary, uid} of events of calendar "Meetings"
end tell

tell application "Calendar"
    tell calendar "omer.hamerman@zesty.co"
      repeat with e in (events where start date > d and start date < d + 7200)
        properties of e
        d + 7200
      end repeat
    end tell
end tell
