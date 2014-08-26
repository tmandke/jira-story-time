#!/usr/bin/env ruby

RELOAD_SCRIPT = <<SCRIPT
tell application "Google Chrome" to tell the active tab of its first window
  activate
  tell application "System Events" to keystroke "r" using { control down, shift down }
  reload
end tell
SCRIPT

puts "be sure to configure chrome to reload on ctl-shift-r"

while true do
  puts "space to reload, q to quit"
  begin
    system("stty raw -echo")
    str = STDIN.getc
  ensure
    system("stty -raw echo")
  end
  
  case str
  when ' ', '\n' 
    system "clear"
    puts "reloading"
    system "coffee --output src/js/ --compile src/coffee/"
    system "osascript -e '#{RELOAD_SCRIPT}'"
  when 'q'
    break
  end
end