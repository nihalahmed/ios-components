# CellObject

![Version](https://img.shields.io/badge/pod-v1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)
![Platform](https://img.shields.io/badge/platform-ios-red.svg)

CellObject provides a set of protocols which allows the data source to drive collection views. An object which conforms to CellObject is responsible to configure the cell used to display it. This means that all the code which would typically be found in `cellForItemAtIndexPath:`, will now be inside the CellObject. This results in cleaner collection view delegate callbacks, lesser code in view controllers and no more relying on checking the index of an item to configure a cell.

The library also provides a CellObjectCollectionView which is specifically designed to use CellObjects. It has a very simple interface and takes in a data model of CellObjects. This allows for the caller to only worry about creating and setting the right data model.

## Example

It is very simple to get started with CellObject. Simply make the object to be used in the data model conform to the CellObject protocol.

```swift
class MyItem: CellObject {
}
```

## Installation

CellObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CellObject', :git => 'https://github.com/Wattpad/ios-components.git'
```

## Author

nihalahmed, nihal.cool@gmail.com

## License

MyLibrary is available under the MIT license. See the LICENSE file for more info.
