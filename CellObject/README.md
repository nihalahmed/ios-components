# CellObject

![Version](https://img.shields.io/badge/pod-v1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)
![Platform](https://img.shields.io/badge/platform-ios-red.svg)

CellObject provides a set of protocols which allows the data source to drive collection views. An object which conforms to CellObject is responsible to configure the cell used to display it. This means that all the code which would typically be found in `cellForItemAtIndexPath:`, will now be inside the CellObject. This results in cleaner collection view delegate callbacks, lesser code in view controllers and no more relying on checking the index of an item to configure a cell.

The library also provides a CellObjectCollectionView which is specifically designed to use CellObjects. It has a very simple interface and takes in a data model of CellObjects. This allows for the caller to only worry about creating and setting the right data model.

## Usage

It is very simple to get started with CellObject. Simply make the object to be used in the data model conform to the CellObject protocol.

The example below makes `MyItem` conform to `CellObject` and uses the UICollectionViewCell to display the item. It is configured to have a red color and of size 100x100.

```swift
class MyItem: CellObject {

    var cellObjectComponent: CellObjectComponent

    init() {
        cellObjectComponent = CellObjectComponent(UICollectionViewCell.self)
        configBlock = { cell in
            cell.contentView.backgroundColor = .red
        }
        sizeBlock = { size in
           return CGSize(width: 100.0, height: 100.0)
        }
    }

}
```

`MyItem` can also be configured to handle selection callbacks by having it conform to `CellObjectSelect`.

```swift
class MyItem: CellObject, CellObjectSelect {

    var cellObjectComponent: CellObjectComponent
    var cellObjectSelectComponent = CellObjectSelectComponent()

    init() {
        cellObjectComponent = CellObjectComponent(UICollectionViewCell.self)
        // Set the configBlock and sizeBlock.
        selectBlock = {
            // Open the item.
        }
    }

}
```

`MyItem` can further be configured to handle display callbacks by having it conform to `CellObjectDisplayComponent`.

```swift
class MyItem: CellObject, CellObjectDisplay {

    var cellObjectComponent: CellObjectComponent
    var cellObjectDisplayComponent = CellObjectDisplayComponent()

    init() {
        cellObjectComponent = CellObjectComponent(UICollectionViewCell.self)
        // Set the configBlock and sizeBlock.
        willDisplayBlock = { cell in
            // Configure the cell before it will be displayed.
        }
    }

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
