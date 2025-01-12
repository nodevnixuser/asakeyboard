# asakeyboard
use android as usb keyboard emulator

## Dependency list
* https://f-droid.org/tr/packages/net.tjado.usbgadget/
* kbd (for showkey)
* tsu (for sudo)

## HOW-TO
* Set your device as keyboard via USB Gadget tool.
* install the necessary packages.
> pkg install kbd

> pkg install tsu
* #### or
> apt install tsu

> apt install kbd
* ### Stages of operation
* git clone https://github.com/nodevnixuser/asakeyboard.git
> sudo bash usbkeyboard.sh
* after running it, it mostly works except for some keys
* no capitalization support.
* only for smart people with bluetooth keyboards (me) to enter boot sequence and bios.
* Yes only for rooted phones
