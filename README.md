Safecast Drive iOS app
=======================

![Drivecast](Assets/drivecast.png)

Safecast Drive is an app that enables you to:

- Connect with your bGeigieNano (as long as you have the Bluetooth LE module installed) record data and upload them to the [Safecast API](https://api.safecast.org/) directly. No need to remove your MicroSD card anymore!
- Access previous logs and update their status.

# Supported devices

In the current version, Safecast Drive is only compatible with the [bGeigieNano geiger counter](http://blog.safecast.org/bgeigie-nano/) equipped with a [BLEBee module](https://github.com/michaelkroll/BLEbee).

![bGeigieNano](Assets/bgeigienano.png)

Other ressources about the BLE Bee module.
- [Dr Michael Kroll's blog](http://www.mkroll.mobi/?page_id=1834)
- [Seeed Studio wiki](http://www.seeedstudio.com/wiki/BLE_Bee)
- [Where to buy it?](https://www.seeedstudio.com/depot/BLEbee-v20-p-2461.html)

# Technical details

This app is writen in swift 2.1 using the MVVM design pattern with some use of functional reactive programming.

## External tools and libraries

For external library management, we rely on CocoaPods. If you are not familiar with the process, please refer to the (https://cocoapods.org/ "documentation"):

- [Alamofire](https://github.com/Alamofire/Alamofire)
- [AngleGradientLayer](https://github.com/paiv/AngleGradientLayer)
- [BEMSimpleLineGraph](https://github.com/Boris-Em/BEMSimpleLineGraph)
- [Cocoapods](https://cocoapods.org)
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)
- [KVNProgress](https://github.com/kevin-hirsch/KVNProgress)
- [Realm Swift](https://realm.io)
- [Spinkit ObjC](https://github.com/raymondjavaxx/SpinKit-ObjC)
- [SnapKit](https://github.com/SwiftyJSON/SwiftyJSON)
- [SwiftyJSON](https://github.com/Alamofire/Alamofire)
- [SwiftGen](https://github.com/AliSoftware/SwiftGen)
- [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)

Most of the assets we use in the app for icons are generously provided by [Icons8](https://icons8.com) in support to our open-source initiative.

# Licenses we use

Licensing can be confusing. This is why we provide a [handy little guide](http://blog.safecast.org/faq/licenses) about what licenses we use and how we use them.

# Learn more about us

Safecast is an international, volunteer-centered organization devoted to open citizen science for the environment. After the devastating earthquake and tsunami which struck eastern Japan on March 11, 2011, and the subsequent meltdown of the Fukushima Daiichi Nuclear Power Plant, accurate and trustworthy radiation information was publicly unavailable. Safecast was formed in response, and quickly began monitoring, collecting, and openly sharing information on environmental radiation and other pollutants, growing quickly in size, scope, and geographical reach. Our mission is to provide citizens worldwide with the tools they need to inform themselves by gathering and sharing accurate environmental data in an open and participatory fashion.

![Drivecast](Assets/radiation.png)

For detailed information about the organisation:

- [Access the map](http://safecast.org/tilemap/)
- [Visit our blog](http://blog.safecast.org)
- [Read the FAQ](http://blog.safecast.org/faq)

You can also watch an episode of the excellent video series called “The Power of Privacy” featuring Safecast at The Guardian online:

[![Guardian video](Assets/guardian.png)](https://www.youtube.com/watch?v=Dr-zaBDRHsc "The power of privacy (4/5): Open data: mapping the fallout from Fukushima")
