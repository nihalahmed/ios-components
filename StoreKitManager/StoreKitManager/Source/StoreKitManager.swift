//
//  StoreKitManager.swift
//  StoreKitManager
//
//  Created by Nihal on 2017-01-28.
//  Copyright © 2017 Wattpad. All rights reserved.
//

import Foundation
import RMStoreWP

/// Error codes for the manager.
public enum StoreKitManagerError : Int {
    
    static let domain = "StoreKitManagerErrorDomain"
    
    /// The product could not be found on the App Store.
    case ProductNotFound
    
    /// Product information could not be fetched.
    case FailedToGetProducts
    
}

/// Handles in app purchases, restoring purchases and providing subscription information.
public class StoreKitManager {
    
    private var rmStore: RMStore
    
    /// This will be set to true when the app receipt is verified. 
    /// It is updated when a product is purchased or purchases are restored.
    private var appReceiptVerified = false
    
    public init(rmStore: RMStore) {
        self.rmStore = rmStore
        setUp()
    }
    
    private func setUp() {
        appReceiptVerified = verifyAppReceipt()
        if appReceiptVerified {
            logDebugMsg(msg: "Initialized with app receipt verified.")
        } else {
            logDebugMsg(msg: "Initialized with app receipt not verified.")
        }
    }
    
    /// Returns true if the subscription with the given identifier is active.
    ///
    /// - Parameters:
    ///     - productIdentifier: The product identifier of the subscription.
    public func isAutoRenewableSubscriptionActive(productIdentifier: String) -> Bool {
        guard let receipt = RMAppReceipt.bundle() else {
            logDebugMsg(msg: "Failed to check subscription status because app receipt could not be found.")
            return false
        }
        if !appReceiptVerified {
            logDebugMsg(msg: "Failed to check subscription status because app receipt is not verified.")
            return false
        }
        return receipt.containsActiveAutoRenewableSubscription(ofProductIdentifier: productIdentifier, for: Date())
    }
    
    /// Returns true if any subscription is active.
    public func isAnyAutoRenewableSubscriptionActive() -> Bool {
        guard let receipt = RMAppReceipt.bundle() else {
            logDebugMsg(msg: "Failed to check subscription status because app receipt could not be found.")
            return false
        }
        if !appReceiptVerified {
            logDebugMsg(msg: "Failed to check subscription status because app receipt is not verified.")
            return false
        }
        let date = Date()
        for iap in receipt.inAppPurchases {
            if let iap = iap as? RMAppReceiptIAP {
                if iap.subscriptionExpirationDate != nil, iap.isActiveAutoRenewableSubscription(for: date){
                    return true
                }
            }
        }
        return false
    }
    
    /// Purchases a product with the given identifier.
    ///
    /// - Parameters:
    ///     - productIdentifier: The identifier of the product.
    ///     - completion: The block to be called upon completion.
    ///     - success: Set to true if the purchase was successful.
    ///     - product: The product that was purchased. Returned if success is true.
    ///     - error: The error that occurred when purchasing. Returned if success is false.
    public func purchaseProduct(productIdentifier: String, completion: @escaping (_ success: Bool, _ product: SKProduct?, _ error: NSError?) -> Void) {
        if let product = rmStore.product(forIdentifier: productIdentifier) {
            logDebugMsg(msg: "Product found for identifier \(productIdentifier). Adding payment.")
            purchaseValidProduct(productIdentifier: productIdentifier, completion: { (success, error) in
                if success {
                    completion(true, product, nil)
                } else {
                    completion(false, nil, nil)
                }
            })
        } else {
            logDebugMsg(msg: "Product not found for identifier \(productIdentifier). Fetching products list.")
            rmStore.requestProducts([productIdentifier], success: { (products, invalidProductIdentifiers) in
                if let product = self.rmStore.product(forIdentifier: productIdentifier) {
                    self.logDebugMsg(msg: "Product found for identifier \(productIdentifier) after fetching products list. Adding payment.")
                    self.purchaseValidProduct(productIdentifier: productIdentifier, completion: { (success, error) in
                        if success {
                            completion(true, product, nil)
                        } else {
                            completion(false, nil, nil)
                        }
                    })
                } else {
                    self.logDebugMsg(msg: "Product not found for identifier \(productIdentifier) after fetching products list. Cannot add payment.")
                    let e = NSError(domain:StoreKitManagerError.domain, code:StoreKitManagerError.ProductNotFound.rawValue, userInfo:nil)
                    completion(false, nil, e)
                }
            }) { (error) in
                self.logDebugMsg(msg: "Failed to fetch products list with error \(String(describing: error)).")
                let e = NSError(domain:StoreKitManagerError.domain, code:StoreKitManagerError.FailedToGetProducts.rawValue, userInfo:nil)
                completion(false, nil, e)
            }
        }
    }
    
    /// Restores all transactions.
    ///
    /// - Parameters:
    ///     - completion: The block to be called upon completion.
    ///     - success: Set to true if the restore was successful.
    ///     - error: The error that occurred when restoring. Returned if success is false.
    public func restoreTransactions(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        rmStore.restoreTransactions(onSuccess: { (transactions) in
            self.logDebugMsg(msg: "Restored transactions.")
            if !self.appReceiptVerified {
                self.appReceiptVerified = self.verifyAppReceipt()
                if self.appReceiptVerified {
                    self.logDebugMsg(msg: "App app receipt verified after restoring transactions.")
                } else {
                    self.logDebugMsg(msg: "Failed to verify app receipt after restoring transactions.")
                }
            }
            completion(true, nil)
        }) { (error) in
            self.logDebugMsg(msg: "Failed to restore transactions with error \(String(describing: error)).")
            completion(false, error)
        }
    }
    
    /// Fetches information for products with the given identifiers from the App Store.
    /// The information is cached for the duration of the app session.
    ///
    /// - Parameters:
    ///     - productIdentifiers: The list of product identifiers.
    ///     - completion: The block to be called upon completion.
    ///     - success: Set to true if the fetch was successful.
    ///     - products: Mapping of product identifiers to their products. Returned if success is true.
    ///     - invalid: A list of invalid product identifiers. Returned if success is true.
    ///     - error: The error that occurred when fetching information. Returned if success is false.
    public func fetchInfoForProducts(productIdentifiers: Set<String>, completion: @escaping (
        _ success: Bool, _ products: [String : SKProduct]?, _ invalid: Set<String>?, _ error: Error?) -> Void) {
        var productsInfo: [String : SKProduct] = [:]
        var productIdentifiersToFetch = Set<String>()
        for productIdentifier in productIdentifiers {
            if let productInfo = rmStore.product(forIdentifier: productIdentifier) {
                productsInfo[productIdentifier] = productInfo
            } else {
                productIdentifiersToFetch.insert(productIdentifier)
            }
        }
        if (productsInfo.count == productIdentifiers.count) {
            self.logDebugMsg(msg: "Returning cached info for product identifiers \(productIdentifiers).")
            completion(true, productsInfo, nil, nil)
            return
        }
        var productIdentifiersFailedToFetch = Set<String>()
        rmStore.requestProducts(productIdentifiersToFetch, success: { (products, invalidProductIdentifiers) in
            for productIdentifier in productIdentifiersToFetch {
                if let productInfo = self.rmStore.product(forIdentifier: productIdentifier) {
                    productsInfo[productIdentifier] = productInfo
                } else {
                    productIdentifiersFailedToFetch.insert(productIdentifier)
                }
            }
            self.logDebugMsg(msg: "Fetched info for product identifiers \(productsInfo.keys). Failed to fetch info for product identifiers \(productIdentifiersFailedToFetch).")
            completion(true, productsInfo, productIdentifiersFailedToFetch, nil)
        }) { (error) in
            self.logDebugMsg(msg: "Failed to fetch info for product identifiers \(productIdentifiers) with error \(String(describing: error)).")
            completion(false, nil, nil, error)
        }
    }
    
    private func verifyAppReceipt() -> Bool {
        return RMStoreAppReceiptVerifier().verifyAppReceipt()
    }
    
    private func purchaseValidProduct(productIdentifier: String, completion: @escaping (Bool, Error?) -> Void) {
        rmStore.addPayment(productIdentifier, success: { (transaction) in
            self.logDebugMsg(msg: "Purchased product with identifier \(productIdentifier).")
            if !self.appReceiptVerified {
                self.appReceiptVerified = self.verifyAppReceipt()
                if self.appReceiptVerified {
                    self.logDebugMsg(msg: "App receipt verified after purchasing product.")
                } else {
                    self.logDebugMsg(msg: "Failed to verify app receipt after purchasing product.")
                }
            }
            completion(true, nil)
        }, failure: { (transaction, error) in
            self.logDebugMsg(msg: "Failed to purchase product with identifier \(productIdentifier) with error \(String(describing: error)).")
            completion(false, error)
        })
    }
    
    private func logDebugMsg(msg: String) {
        print("\(String(describing: type(of: self))): \(msg)")
    }
    
    /// Returns a product for the given product identifier if it was already fetched earlier.
    ///
    /// - Parameters:
    ///     - productIdentifier: The identifier of the product.
    public func product(forIdentifier identifier: String) -> SKProduct? {
        return rmStore.product(forIdentifier: identifier)
    }
    
}
