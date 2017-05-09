Pod::Spec.new do |s|
  s.name         = "CellObject"
  s.version      = "1.0.0"
  s.summary      = "Protocol which allows for data driven collection views."
  s.description  = "CellObject is a set of protocols which allows the data source to drive collection views. The CellObject provides the collection view the necessary data to render a cell. The library also includes a CellObjectCollectionView which is designed to render a data model consisting of CellObjects."
  s.homepage     = "https://github.com/nihalahmed/ios-components/CellObject"
  s.license      = { :type => "MIT" }
  s.author       = { "Nihal Ahmed" => "nihal.cool@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/nihalahmed/ios-components.git" }
  s.source_files = "CellObject/CellObject/Source/**/*.swift"
  s.dependency "TLIndexPathTools"
end
