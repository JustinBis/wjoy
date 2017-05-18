# WJoy

You must have SIP disabled for this application to work. Please disable it by booting your Mac into recovery mode, opening the Terminal and running:

```sh
csrutil disable
```

You may read more here: http://www.imore.com/el-capitan-system-integrity-protection-helps-keep-malware-away

##### Installation Instructions

 1. Download WJoy here: https://www.dropbox.com/s/oowoqvnx091bcjx/WJoy%20Package.zip?dl=1
 2. Move the `wjoy.kext` file to `/Library/Extensions`
 3. Move the `WJoy.app` to `/Applications`
 4. Turn on Bluetooth.
 5. Start the WJoy application.
 6. In the system tray, click the WJoy icon and click Begin Discovery.
 7. Turn on the Wiimote or Wii U Pro Controller by pressing any key on it.
 8. Press the sync button (red flat button on the controller) while in discovery mode.
 9. Once connected, configure the Wii U Pro controller as a Steam controller in Steam Big Picture Mode. Read more here: https://www.howtogeek.com/234427/how-to-remap-buttons-on-your-steam-controller/
 
In my experience, Unity games for Mac do not support the Wii U Pro Controller, since they tend to use the XInput package. There is no application that emulates an Xbox controller for Mac.

Working:

 - Binding of Isaac
 - Gang Beasts
 - DolphinEmu
 - Antichamber
 - Hotline Miami
 - Teleglitch

Not working:

 - Ultimate Chicken Horse
 - Broforce
 - Monaco
 - Superhot
