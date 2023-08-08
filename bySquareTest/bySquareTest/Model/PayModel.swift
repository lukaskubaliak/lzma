//
//  PayModel.swift
//  bySquareTest
//
//  Created by Lukáš Kubaliak on 27/06/2023.
//

import Foundation

struct PayModel {
    
    let header: PayHeader?
    let body: PayBody?
    
}

struct PayHeader {
    
    let bySquareType: UInt8
    let version: UInt8
    let documentType: UInt8
    let reserved: UInt8
    
    init(bySquareType: UInt8, version: UInt8, documentType: UInt8, reserved: UInt8) {
        self.bySquareType = bySquareType
        self.version = version
        self.documentType = documentType
        self.reserved = reserved
    }

}

struct PayBody {
    
    let invoiceId: String?
    let paymentCount: Int?
    let paymentOptions: Int?
    let amount: Float?
    let currencyCode: String?
    let paymentDueDate: String?//Date?
    let variableSymbol: String?
    let constantSymbol: String?
    let specificSymbol: String?
    let originatorsReferenceInformation: String?
    let paymentNote: String?
    let bankAccounts: Int?
    let iban: String?
    let bic: String?
    let standingOrderExt: Int?
    let day: Int?
    let month: Int?
    let periodicity: String?
    let lastDate: String?//Date
    let directDebitExt: Int?
    let directDebitScheme: Int?
    let directDebitType: Int?
    let variableSymbol2: String?
    let specificSymbol2: String?
    let originatorsReferenceInformation2: String?
    let mandateId: String?
    let creditorId: String?
    let contractId: String?
    let maxAmount: Float?
    let validTillDate: String?//Date
    let beneficiaryName: String?
    let beneficiaryAddressLine1: String?
    let beneficiaryAddressLine2: String?
    
    init?(bytes: [[UInt8]]) {
        let dictionary = bytes.toDictionary()
        
        self.invoiceId = dictionary["invoiceId"] as? String
        self.paymentCount = (dictionary["paymentCount"] as? NSString)?.integerValue
        self.paymentOptions = (dictionary["paymentOptions"] as? NSString)?.integerValue
        self.amount = (dictionary["amount"] as? NSString)?.floatValue
        self.currencyCode = dictionary["currencyCode"] as? String
        self.paymentDueDate = (dictionary["paymentDueDate"] as? String)?.formattedDateString()
        self.variableSymbol = dictionary["variableSymbol"] as? String
        self.constantSymbol = dictionary["constantSymbol"] as? String
        self.specificSymbol = dictionary["specificSymbol"] as? String
        self.originatorsReferenceInformation = dictionary["originatorsReferenceInformation"] as? String
        self.paymentNote = dictionary["paymentNote"] as? String
        self.bankAccounts = (dictionary["bankAccounts"] as? NSString)?.integerValue
        self.iban = dictionary["iban"] as? String
        self.bic = dictionary["bic"] as? String
        self.standingOrderExt = (dictionary["standingOrderExt"] as? NSString)?.integerValue
        self.day = (dictionary["day"] as? NSString)?.integerValue
        self.month = (dictionary["month"] as? NSString)?.integerValue
        self.periodicity = dictionary["periodicity"] as? String
        self.lastDate = dictionary["lastDate"] as? String
        self.directDebitExt = (dictionary["directDebitExt"] as? NSString)?.integerValue
        self.directDebitScheme = (dictionary["directDebitScheme"] as? NSString)?.integerValue
        self.directDebitType = (dictionary["directDebitType"] as? NSString)?.integerValue
        self.variableSymbol2 = dictionary["variableSymbol2"] as? String
        self.specificSymbol2 = dictionary["specificSymbol2"] as? String
        self.originatorsReferenceInformation2 = dictionary["originatorsReferenceInformation2"] as? String
        self.mandateId = dictionary["mandateId"] as? String
        self.creditorId = dictionary["creditorId"] as? String
        self.contractId = dictionary["contractId"] as? String
        self.maxAmount = (dictionary["maxAmount"] as? NSString)?.floatValue
        self.validTillDate = (dictionary["validTillDate"] as? String)?.formattedDateString()
        self.beneficiaryName = dictionary["beneficiaryName"] as? String
        self.beneficiaryAddressLine1 = dictionary["beneficiaryAddressLine1"] as? String
        self.beneficiaryAddressLine2 = dictionary["beneficiaryAddressLine2"] as? String
    }
    
    
}

// MARK: - Bytes to model dictionary

extension [[UInt8]] {
    
    func toDictionary() -> [String: Any?] {
        var dictionary = [String: Any?]()
        
        let keys = [
            "invoiceId",
            "paymentCount",
            "paymentOptions",
            "amount",
            "currencyCode",
            "paymentDueDate",
            "variableSymbol",
            "constantSymbol",
            "specificSymbol",
            "originatorsReferenceInformation",
            "paymentNote",
            "bankAccounts",
            "iban",
            "bic",
            "standingOrderExt",
            "day",
            "month",
            "periodicity",
            "lastDate",
            "directDebitExt",
            "directDebitScheme",
            "directDebitType",
            "variableSymbol",
            "specificSymbol",
            "originatorsReferenceInformation",
            "mandateId",
            "creditorId",
            "contractId",
            "maxAmount",
            "validTillDate",
            "beneficiaryName",
            "beneficiaryAddressLine1",
            "beneficiaryAddressLine2"
        ]
        
        self.enumerated().forEach { index, innerArray in
            guard index < keys.count else { return }
            
            let key = keys[index]
            dictionary[key] = innerArray.toString()
        }
        return dictionary
    }
    
}
