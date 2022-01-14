# Luup-MyiPhone-Locator

# Scope

This is a Luup plugin to track the location of your iPhone/iOS device.

Luup (Lua-UPnP) is a software engine which incorporates Lua, a popular scripting language, and UPnP, the industry standard way to control devices. Luup is the basis of a number of home automation controllers e.g. Micasaverde Vera, Vera Home Control, OpenLuup.

# Compatibility

This plug-in has been tested on the Ezlo Vera Home Control system.

# Features

It supports the following functions:

* Creation a device in UI showing the distance in Km of your iPhone/iOS device
* Updates variables whenever it connects to Apple iCloud

Still to be added..

* Add a button to refresh iPhone location on demand
* Add addiitonal variable to show other related information
* other fixes/updates

# Imstallation / Usage

This installation assumes you are running the latest version of Vera software.

1. Upload the icon mobile.png file to the appropriate storage location on your controller. For Vera that's `/www/cmh/skins/default/icons`
2. Upload the .xml and .json file in the repository to the appropriate storage location on your controller. For Vera that's via Apps/Develop Apps/Luup files/
3. Create the decice instance via the appropriate route. For Vera that's Apps/Develop Apps/Create Device/ and putting "D_MyiPhone1.xml" into the Upnp Device Filename box. 
4. Reload luup to establish the device and then reload luup again (just to be sure) and you should be good to go
5. Enter is all the required credentials which are your AppleID username and password, your home logitude and latitude coordinates and the name of the device you are looking to track (as registered with Apple)
6. The install will check that you have provided all the required information and that you can successfully check.

You can configure it quickly by updating the following script and running it in the Lua Startup / Testing window.
````
local lul_device = 189  -- the registered device number of your plugin
local username = "myappleid@domain.com"  -- your AppleID username
local password = "myapplepw" -- your AppleID password
local device = "mydevicename" -- the name of you Apple registered device
local homelatitude = 0.00000
local homelongitude = 0.0000
local COM_SID = "urn:nodecentral-net:serviceId:MyiPhone1"

luup.variable_set(COM_SID, "MyAppleUsername", username , lul_device)
luup.variable_set(COM_SID, "MyApplePassword", password , lul_device)
luup.variable_set(COM_SID, "MyTargetDeviceName", device , lul_device)
luup.variable_set(COM_SID, "MyHomeLatitude", homelatitude , lul_device)
luup.variable_set(COM_SID, "MyHomeLongitude", homelongitude , lul_device) 

luup.reload()
````

# Limitations

While it has been tested, it has not been tested very much and may not support other related devices or those running different firmware.

# Buy me a coffee

If you choose to use/customise or just like this plug-in, feel free to say thanks with a coffee or two.. 
(God knows I drank enough working on this :-)) 

<a href="https://www.paypal.me/nodezero" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

# Screenshots

Once installed, you should see the device listed with the distance your iphone/ios device is away from you.

![BE06074B-E42D-43E5-94F0-2B426D831C5A](https://user-images.githubusercontent.com/4349292/149583617-8e7e6651-24b8-4a61-a7b6-8bcc0fe54be4.jpeg)

# License

Copyright © 2021 Chris Parker (nodecentral)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses
