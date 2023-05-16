# Features

1. Draws spheres (inspired by [Item Locator](https://forum.worldofplayers.de/forum/threads/1577038-Patch-Item-Locator)) around all (in current World) alive & mortal NPCs. Press a key configured at `toggleMortalNPCLocatorKey` option (by default `V`) to toggle rendering on and off. Supports two kinds of display modes ( `considerG1DoubleXPGlitch` option):
    - NPCs which weren't beaten yet; Such NPCs will be marked by green sphere;
    - NPCs which weren't beaten or killed (if you want to exploit double XP glitch in G1); Beaten NPCs will be marked by an orange sphere;
    
2. Shows a text alert when NPC dies in a way that leads to player missing XP. In addition to that, draws a yellow sphere around the NPC which currently is hardcoded to display for 60 seconds;
    
### TLDR
### No (mortal) NPC can hide from you now!
![alt No (mortal) NPC can hide from you now!](pic.png "No (mortal) NPC can hide from you now!")
### No NPC will take your XP quietly ever again!
![alt No NPC will take your XP quietly ever again!](pic2.png "No NPC will take your XP quietly ever again!")

# How to install
1. Have [Ninja](https://github.com/szapp/Ninja) installed.
2. Drop `MaxXPHelper.vdf` file into `<gothic-main-dir>/Data`
# Gothic.ini options
After installing, start the game to get the defaults set in Gothic.ini in `[MaxXPHelper-V1]` section.

```
[MAXXPHELPER-V1]
; ... Key constant name as defined in Icarus (https://github.com/Lehona/Ikarus/blob/a7bcd2b19ab3ba05b8d4c6e8068f8c3cae9540a2/Ikarus_Const_G1.d#L181)
toggleMortalNPCLocatorKey=KEY_V
; ... Defaults to 1 in Gothic 1, otherwise it's 0 as it makes no sense to have this on in G2 NotR (unless you run some mod that enables the double XP glitch there). 
; ... If set to 1 and alerts are on, will alert if player kills human NPC without knocking them down first (to double dip XP).
considerG1DoubleXPGlitch=1
; ... Defaults to 0 and will then ignore NPCs with level equal to 0 (like Mud or self-summoned creatures like G2 NotR).
considerLevelZeroNPC=0
; ... Enable (1)/Disable (0) text alerts and spheres when NPC dies and player lost XP.
showMissedXPOnNPCDeathAlerts=1
```
# Known Issues 
todo

1. Currently testing in Gothic 1.
2. Testing Gothic 2 NotR next

# Build Instructions
todo

# License
MIT License

Copyright (c) 2023 Avenire

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.