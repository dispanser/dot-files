#!/usr/bin/env fish

# X12
set -l TOUCH_DEV "Wacom HID 525C Finger"
# Wacom HID 525C Pen
set -l ID 525C
# X1 T3
# set -l TOUCH_DEV "Wacom HID 511A Finger"
# set -l ID 511A

monitor-sensor | while read -l orientation
  set -l match (string match -r "normal|left-up" $orientation)
  if test -z $match
    echo zero match: ... $match ...
    continue
  end
  echo tp\; match is non-zero $match
  if [ $match = "left-up" ];
    echo "rotating left"
    xinput set-prop "Wacom HID $ID Finger" 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1
    xinput set-prop "Wacom HID $ID Pen" 'libinput Calibration Matrix' 0 -1 1 1 0 0 0 0 1
    xrandr -o left
  else if [ $match = "normal" ]
    echo "back to normal"
    xinput set-prop "Wacom HID $ID Finger"  'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1
    xinput set-prop "Wacom HID $ID Pen"  'libinput Calibration Matrix' 1 0 0 0 1 0 0 0 1
    xrandr -o normal
  end
end

# Accelerometer orientation changed: normal

# if [ $argv[1] = "left" ]
#   echo "rotating left"
#   xinput set-prop 'Wacom HID 511A Finger' 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1
#   xrandr -o left
# else
#   echo "back to normal"
#   xinput set-prop 'Wacom HID 511A Finger' 'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1
#   xrandr -o normal
# end
