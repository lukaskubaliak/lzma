//
//  ViewController.swift
//  bySquareTest
//
//  Created by Lukáš Kubaliak on 10/06/2023.
//

import Foundation
import UIKit
import LZCompression
//import LzmaSDK_ObjC
//import PLzmaSDK
//import BitByteData
//import Compression
//import SWCompression
//import PythonKit
//import DataCompression

class ViewController: UIViewController {
    
    var payModel: PayModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qrCode = "000700009QADK99HI1H3NE0MM4QECRP0PCPNBBI3SIGMU9F25I2J4RIQ7EGTGFV15HSP8Q48DT14LEE2P1LPOR7Q2NDFCD6DC8ERJRSBCL2RVV4JUR0NKHO2K9F8O62N7SGL51T4AEM1U000"
     
        
        /// bytes of decompressed qrCode string by LZMA
        let bytes: [UInt8] = [50, 48, 50, 51, 48, 48, 48, 49, 9, 49, 9, 49, 9, 53, 56, 50, 9, 69, 85, 82, 9, 50, 48, 50, 51, 48, 53, 48, 50, 9, 50, 48, 50, 51, 48, 48, 48, 49, 9, 9, 9, 9, 195, 131, 194, 154, 104, 114, 97, 100, 97, 32, 102, 97, 107, 116, 195, 131, 194, 161, 114, 121, 58, 32, 50, 48, 50, 51, 48, 48, 48, 49, 9, 49, 9, 83, 75, 55, 51, 48, 57, 48, 48, 48, 48, 48, 48, 48, 48, 48, 51, 56, 50, 50, 52, 49, 48, 54, 48, 9, 71, 73, 66, 65, 83, 75, 66, 88, 9, 48, 9, 48]
        
        
        /// Decode model
        if let data = qrCode.base32HexDecodedData {

            let header = interpretHeader(data: data)
            let body = interpretBody(bytes: bytes)
            
            payModel = PayModel(
                header: header,
                body: body
            )
        }
        
        /// Encode model
        if let payModel = payModel {
            print("model: \(payModel)")
            
            let headerEncoded = encode(header: payModel.header)
            print("header: \(headerEncoded)")
        }
    }
    
}

// MARK: - Encode model

extension ViewController {
    
    // MARK: - Encode header
    
    func encode(header: PayHeader?) -> String? {
        guard let header = header else { return nil }
        
        var resultString: String = ""
        [
            header.bySquareType,
            header.version,
            header.documentType,
            header.reserved
        ].forEach {
            var binaryString = String($0, radix: 2)
            let leadingZerosCount = 4 - binaryString.count
            if leadingZerosCount > 0 {
                let leadingZeros = String(repeating: "0", count: leadingZerosCount)
                resultString += leadingZeros + binaryString
            }
        }
        return resultString
    }
    
}

// MARK: - Interpet Model

extension ViewController {
    
    // MARK: - Header
    
    func interpretHeader(data: Data) -> PayHeader? {
        guard data.count >= 2 else { return nil } // Ensure that the data contains at least 2 bytes
        
        var headerArray = [UInt8]()
        
        for byteIndex in 0..<2 {
            let byte = data[byteIndex]
            
            headerArray.append((byte & 0xF0) >> 4) // First 4 bits from byte
            headerArray.append(byte & 0x0F) // Last 4 bits from byte
        }
        
        return PayHeader(
            bySquareType: headerArray[0],
            version: headerArray[1],
            documentType: headerArray[2],
            reserved: headerArray[3]
        )
    }
    
    // MARK: - Body
    
    func interpretBody(bytes: [UInt8]) -> PayBody? {
        /// Convert [UInt8] to 2D array
        ///  &&
        /// replace 9 with empty array
        var tmp = [UInt8]()
        var result = [[UInt8]]()
        bytes.enumerated().forEach { index, value in
            if value == 9 {
                result.append(tmp)
                tmp = []
            } else {
                if tmp.isEmpty, index != 0, index != bytes.count - 1 {
                    result.append([])
                }
                tmp.append(value)
            }
        }
        
        /// Remove tabulators
        var newResult = [[UInt8]]()
        result.enumerated().forEach { index, innerArray in
            if index > 0,
               !innerArray.isEmpty || result[index - 1].isEmpty {
                newResult.append(innerArray)
            } else if !result[index].isEmpty {
                newResult.append(innerArray)
            }
        }
        
        return PayBody(bytes: newResult)
    }
    
}


// MARK: - Conversions

extension ViewController {
    
    func dataToBitStrings(_ data: Data) -> [String] {
        let byteSize = 8
        //        let bitsPerByte = UInt8(byteSize)
        
        var bitStrings = [String]()
        
        for byte in data {
            var bitString = ""
            
            for bitIndex in (0..<byteSize).reversed() {
                let mask: UInt8 = 1 << bitIndex
                let bitValue = (byte & mask) != 0 ? "1" : "0"
                bitString.append(bitValue)
            }
            
            bitStrings.append(bitString)
        }
        
        return bitStrings
    }
    
    func bitStringsToData(_ bitStrings: [String]) -> Data? {
        let byteSize = 8
        //        let bitsPerByte = UInt8(byteSize)
        
        var bytes = [UInt8]()
        
        for bitString in bitStrings {
            guard bitString.count == byteSize else {
                print("Invalid bit string: \(bitString)")
                return nil
            }
            
            var byte: UInt8 = 0
            
            for (bitIndex, bitChar) in bitString.enumerated() {
                guard let bitValue = UInt8(String(bitChar), radix: 2) else {
                    print("Invalid bit value: \(bitChar)")
                    return nil
                }
                
                byte |= bitValue << (byteSize - 1 - bitIndex)
            }
            
            bytes.append(byte)
        }
        
        return Data(bytes)
    }
    
    
    func stringToData(bitString: String) -> Data {
        var byteString = ""
        var index = bitString.startIndex
        
        while index < bitString.endIndex {
            let endIndex = bitString.index(index, offsetBy: 8, limitedBy: bitString.endIndex) ?? bitString.endIndex
            let byte = bitString[index..<endIndex]
            byteString += byte + " "
            index = endIndex
        }
        
        byteString.removeLast() // Remove the trailing space
        
        let bytes = byteString.components(separatedBy: " ").compactMap { UInt8($0, radix: 2) }
        let data = Data(bytes: bytes)
        
        return data
    }
    
    func splitBitString(_ bitString: String) -> [String] {
        let byteSize = 8
        var result = [String]()
        
        var currentIndex = bitString.startIndex
        
        while currentIndex < bitString.endIndex {
            let endIndex = bitString.index(currentIndex, offsetBy: byteSize, limitedBy: bitString.endIndex) ?? bitString.endIndex
            let substring = String(bitString[currentIndex..<endIndex])
            result.append(substring)
            
            currentIndex = endIndex
        }
        
        return result
    }
    
}
