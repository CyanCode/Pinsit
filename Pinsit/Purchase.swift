//
//  Purchase.swift
//  Pinsit
//
//  Created by Walker Christie on 9/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import StoreKit

class Purchase: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {    
    var product: SKProduct?
    var productID: NSString?
    var responder: AnyObject?
    var responderView: UIView?
    
    func getProductID() {
        if (SKPaymentQueue.canMakePayments()) {
            var set = NSMutableSet()
            set.addObject(productID!)
            
            let request = SKProductsRequest(productIdentifiers: set)
            request.delegate = self
            
            //Process code
        } else {
            println("Enable in-app purchases in settings")
        }
    }
    
    func createPurchase() {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func restorePurchase() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    //Payment processing..
    func unlockPurchase() {
        //Code here..
    }
    
    func paymentRestored() {
        //Code here..
    }
    
    func paymentComplete() {
        //Code here
    }
    
    //Delegate Methods
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        self.unlockPurchase()
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var products: NSArray = response.products
        
        if (products.count != 0) {
            product = products[0] as? SKProduct
            self.createPurchase()
        } else {
            println("Product not found..")
        }
        
        products = response.invalidProductIdentifiers
        
        for currentProd in products {
            println("Product not found: \(currentProd)")
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions {
            switch (transaction.transactionState!) {
            case SKPaymentTransactionState.Purchased:
                self.paymentComplete()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
            case SKPaymentTransactionState.Failed:
                println("Purchase failed with error: \(transaction.error)")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                //Process close progress
                break
            case SKPaymentTransactionState.Purchasing:
                println("Payment being processed..")
                break
            case SKPaymentTransactionState.Restored:
                println("Payment restored")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
            default:
                break
            }
        }
    }
}