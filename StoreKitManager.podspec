Pod::Spec.new do |s|
  s.name         = "StoreKitManager"
  s.version      = "1.0.0"
  s.summary      = "Handles in app purchases, restoring purchases and providing subscription information."
  s.description  = "StoreKitManager helps in fetching in app purchase products, purchasing them, restoring earlier purchases and also providing subscription information."
  s.homepage     = "https://github.com/Wattpad/ios-components/StoreKitManager"
  s.license      = { :type => "MIT", :file => 'StoreKitManager/LICENSE' }
  s.author       = { "Nihal Ahmed" => "nihal.cool@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Wattpad/ios-components.git" }
  s.source_files = "StoreKitManager/StoreKitManager/Source/**/*.swift"
  s.dependency "RMStoreWP/AppReceiptVerifier", "0.7.1.1"
end
