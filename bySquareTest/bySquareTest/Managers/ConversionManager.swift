//
//  ConversionManager.swift
//  bySquareTest
//
//  Created by Lukáš Kubaliak on 05/07/2023.
//

import Foundation

final class ConversionManager {
    
    // MARK: - Constants - Public
    
    static let shared: ConversionManager = ConversionManager()
    
    // MARK: - Constants - Private
    
    private let __: UInt8 = 255
    
    // MARK: - Variables - Computed
    
    private var decodeTable: [UInt8] {
        [
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x20 - 0x2F
            0, 1, 2, 3,  4, 5, 6, 7,  8, 9,__,__, __,__,__,__,  // 0x30 - 0x3F
            __,10,11,12, 13,14,15,16, 17,18,19,20, 21,22,23,24,  // 0x40 - 0x4F
            25,26,27,28, 29,30,31,__, __,__,__,__, __,__,__,__,  // 0x50 - 0x5F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x60 - 0x6F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x70 - 0x7F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
            __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
        ]
    }
    
    private var encodeTable: [Int8] { ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V"].map { (c: UnicodeScalar) -> Int8 in Int8(c.value) }
    }
    
}

// MARK: - Base 32 HEX

extension ConversionManager {
    
    func base32HexToBinary(_ base32Hex: String) -> String? {
        var binaryString = ""
        
        for character in base32Hex {
            // Get the ASCII value of the character
            guard let asciiValue = character.asciiValue else {
                print(" Get the ASCII value of the character")
                return nil
            }
            // Check if the ASCII value is within the valid range
            guard asciiValue < decodeTable.count else {
                print(" Check if the ASCII value is within the valid range")
                return nil
            }
            
            // Get the decode table entry for the ASCII value
            let decodeValue = decodeTable[Int(asciiValue)]
            
            // Convert the decode value to a binary string
            let binaryValue = String(decodeValue, radix: 2)
            
            // Pad the binary value with leading zeros if necessary
            let paddedBinaryValue = binaryValue.leftPadding(toLength: 5, withPad: "0")
            
            // Append the binary value to the result
            binaryString += "\(paddedBinaryValue)"
        }
        
        return binaryString
    }
    
    func test(_ data: UnsafeRawPointer, _ length: Int) -> String {
        let table = encodeTable
        
        if length == 0 {
            return ""
        }
        var length = length
    
        var bytes = data.assumingMemoryBound(to: UInt8.self)
    
        let resultBufferSize = Int(ceil(Double(length) / 5)) * 8 + 1    // need null termination
        let resultBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: resultBufferSize)
        var encoded = resultBuffer
    
        // encode regular blocks
        while length >= 5 {
            encoded[0] = table[Int(bytes[0] >> 3)]
            encoded[1] = table[Int((bytes[0] & 0b00000111) << 2 | bytes[1] >> 6)]
            encoded[2] = table[Int((bytes[1] & 0b00111110) >> 1)]
            encoded[3] = table[Int((bytes[1] & 0b00000001) << 4 | bytes[2] >> 4)]
            encoded[4] = table[Int((bytes[2] & 0b00001111) << 1 | bytes[3] >> 7)]
            encoded[5] = table[Int((bytes[3] & 0b01111100) >> 2)]
            encoded[6] = table[Int((bytes[3] & 0b00000011) << 3 | bytes[4] >> 5)]
            encoded[7] = table[Int((bytes[4] & 0b00011111))]
            length -= 5
            encoded = encoded.advanced(by: 8)
            bytes = bytes.advanced(by: 5)
        }
    
        // encode last block
        var byte0, byte1, byte2, byte3, byte4: UInt8
        (byte0, byte1, byte2, byte3, byte4) = (0,0,0,0,0)
        switch length {
        case 4:
            byte3 = bytes[3]
            encoded[6] = table[Int((byte3 & 0b00000011) << 3 | byte4 >> 5)]
            encoded[5] = table[Int((byte3 & 0b01111100) >> 2)]
            fallthrough
        case 3:
            byte2 = bytes[2]
            encoded[4] = table[Int((byte2 & 0b00001111) << 1 | byte3 >> 7)]
            fallthrough
        case 2:
            byte1 = bytes[1]
            encoded[3] = table[Int((byte1 & 0b00000001) << 4 | byte2 >> 4)]
            encoded[2] = table[Int((byte1 & 0b00111110) >> 1)]
            fallthrough
        case 1:
            byte0 = bytes[0]
            encoded[1] = table[Int((byte0 & 0b00000111) << 2 | byte1 >> 6)]
            encoded[0] = table[Int(byte0 >> 3)]
        default: break
        }
    
        // padding
        let pad = Int8(UnicodeScalar("=").value)
        switch length {
        case 0:
            encoded[0] = 0
        case 1:
            encoded[2] = pad
            encoded[3] = pad
            fallthrough
        case 2:
            encoded[4] = pad
            fallthrough
        case 3:
            encoded[5] = pad
            encoded[6] = pad
            fallthrough
        case 4:
            encoded[7] = pad
            fallthrough
        default:
            encoded[8] = 0
            break
        }
    
        // return
        if let base32Encoded = String(validatingUTF8: resultBuffer) {
            resultBuffer.deallocate()
            return base32Encoded
        } else {
            resultBuffer.deallocate()
            fatalError("internal error")
        }
    }
    
}
