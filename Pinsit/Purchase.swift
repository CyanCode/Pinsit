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
    var responderView: UIViewController?
    
    func getProductID() {
        if (SKPaymentQueue.canMakePayments()) {
            var set = NSMutableSet()
            set.addObject(productID!)
            
            let request = SKProductsRequest(productIdentifiers: set)
            request.delegate = self
            
            //Process code
        } else {
            self.errorAlert("Hmm..", message: "Your purchase could not be completed, please ensure that in-app purchases are enabled for Pinsit in your settings!")
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
    
    //MARK: Purchase status methods
    //Call after purchase or restoration
    func unlockPurchase() {
        let f = File()
        f.setUpgradeStatus(true)
    }
    
    //Called when payment is restored
    func paymentRestored() {
        self.successMessage("Your payment for Pinsit has been successfully restored, enjoy!")
        self.unlockPurchase()
    }
    
    func paymentComplete() {
        self.successMessage("Thank you for your purchase!  You may now enjoy all features of Pinsit.")
        self.unlockPurchase()
    }
    
    //MARK: Delegate Methods
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var products: NSArray = response.products
        
        if (products.count != 0) {
            product = products[0] as? SKProduct
            self.createPurchase()
        } else {
            self.errorAlert("Something Went Wrong", message: "An error occured while processing your purchase, please try again!")
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
            case SKPaymentTransactionState.Purchased: //Purchase worked (success)
                self.paymentComplete()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
            case SKPaymentTransactionState.Failed: //Purchase failure
                println("Purchase failed with error: \(transaction.error)")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                //Process close progress
                break
            case SKPaymentTransactionState.Purchasing: //Currently purchasing
                println("Payment being processed..")
                break
            case SKPaymentTransactionState.Restored: //Purchase restored (success)
                println("Payment restored")
                self.paymentRestored()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
            default:
                break
            }
        }
    }
    
    //MARK: Alerts
    private func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        responderView?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func successMessage(message: String) {
        let alert = UIAlertController(title: "Fantastic!", message: message, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        responderView?.presentViewController(alert, animated: true, completion: nil)
    }
}