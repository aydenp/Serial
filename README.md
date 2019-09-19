# Serial

A simple iOS app for looking up an Apple device's serial number.

**Warning:** This app was coded quickly in a night as I needed to buy an iOS device with a specific version. Some of the code is not very good, and the methods used in some places make me want to cry.

![Screenshots](/Assets/Screenshot.png?v2)

[Get it on Dynastic Repo](https://get.dyn.dev/serial)

[Download .ipa File](https://github.com/aydenp/Serial/releases)

## How does it work?

Apple device serial numbers follow a known format that makes it trivial to decode their factory, manufacture week, and unique/product model identifier.

This app uses an Apple support API to find the name of a device, given the 'product model identifier' suffix of a serial number.

Additionally, it infers the OS family based on the device's name. If it matches a known OS type, it will get the highest probable OS version the device shipped with based on the week of manufacture. This is extremely useful if you are trying to buy a device on a certain version.

You may also scan serial number barcodes from Apple product boxes.

## How can I use it?

1. Open the Xcode project (Serial.xcworkspace) in Xcode.

2. Change the app bundle identifier and teams to your own and.

3. Build the app and install it on your iOS device.

## Reporting Issues

If you find a bug or code issue, report it on the [issues page](/issues). Keep in mind that this is for actual bugs, **NOT BUILD ISSUES**. 

## Contributing

Feel free to contribute to the source code of Serial to make it something even better! Just try to adhere to the general coding style throughout, to make it as readable as possible.

## License

This project is licensed under the [MIT license](/LICENSE). Please make sure you comply with its terms while using it in any way.

[Privacy Policy](https://ayden.dev/privacy/serial)

