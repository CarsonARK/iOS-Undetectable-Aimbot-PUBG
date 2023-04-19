Undetected External PUBG Aimbot - Trollstore

Much of the code is 'borrowed' from H5GG, and made to work with C code and a picture and picture window to allow the hack to run code while having PUBG open. 

Example Gameplay: https://drive.google.com/file/d/13abQR9v71zakghCWJEZI2KGefLmnWXLI/view?usp=sharing

Compatability:

    Device should be unjailbroken as to avoid the PUBG Jailbreak detection
    The PUBG App should be installed directly from the App Store

    Your device must be unjailbroken, iOS/IPadOS 14-15.4 / Trollstore Compatable (See trollstore github for full compatability info)

    To use, must download esign++ (trollstore exploit esign)

    This version is built for PUBG 2.5, so any future versions it will not work and offsets must be udpated

Installation:

    To install the .iPA file inside this github, download the app.entitlements and PUBG-external.ipa

    Import both into ESign, and import the app library of PUBG-external.ipa

    ESign Link: https://esign.yyyue.xyz/
    
    After importing the app library you should see the app "Ark IDs" in the Unsigned section, the app doesnt matter its just a small app used to hold the deb file. 

    Click on the Ark IDs app and click Signature, click More Settings, then choose the app.entitlements file as custom entitlments to sign the app with. Sign it and Troll Install. 

    After the app installs with the custom entitlements, you first should open PUBG, then open the installed app. Click "Start" on the Popup, and a black video will appear. Go to the home on your device, and it should be in picture and picture mode. From there open up PUBG and join a match, and as long as the picture and picutre video remains present the aimbot will be activated. If it goes away after some time, simply reopen the app and repeat the process, it only takes a second or 2.

    If you want to edit my hack and make your own, update offsets, or make it work for a different game (it will work undetected on every single game), then download the Theos Project, and edit the Tweak.xm and other files however you want. After you make package, you will need a target app to inject into. My sugguestion is one which is small. Download my .ipa and move the video.mp4 from the .app folder of my app to whatever new app you want to inject into. From there, import that .app folder into Esign, and sign it and click "Add Library" and add the deb file you generated with theos, and then sign it with the custom entitlments in app.entitlements. 


Limitations:

    As of now, I do not know of a way to call function or hook function cross process. If someone discovers a way, feel free to let me know.
    
    You cannot draw on the target app as of now, only having the capabilites to read memory. 
    
    Only works on device versions which are compatable with trollstore. Maybe a similar exploit will emerge in the future which will allow this to work on newer iOS versions, but until that day the versions will be limited. 
    
Improvements:

    If you want to work on this / with this concept yourself, some ponential areas for improvment are as follows:
    
    Instead of using a deb injected into a ipa, you could use xcode to build a custom ipa with all of the same features and then sign it with the entitlements. This could allow you to customize it more.
    
    Figure out a way to call functions or Hook functions. I'm not sure if its possible, and I do not have the time or patience to try, but if you could figure out a way to call functions then it would be more possible to improve aimbot by using line of sight, aswell as in some games making an ESP using the ingame drawing functions. In the same spirit, figuring out a way to hook functions would also be extremely helpful.
    
    Figure out a way to display custom views / images inside the PIP (picture in picture) window. If you could figure out a way to have the hack app record your screen, and display the recorded screen in the PIP view, with a overlay on it, then it would be possible to essentially mirror your screen to the app, draw a custom ESP ontop of the recorded frames, and then display them in the PIP view. While not as effective as a built in ESP, this method could still allow you to have most of the same functionality. Alternativly, if you could figure out a way to just display custom views or images or textures in the PIP view, you could make a Radar instead of a ESP, which would still be useful. 
    
    
    
    


