//
//  ViewController.swift
//  bySquareTest
//
//  Created by Lukáš Kubaliak on 10/06/2023.
//

import Foundation
import UIKit
import LzmaSDK_ObjC
import PLzmaSDK
import BitByteData
import Compression
import SWCompression
import PythonKit
import DataCompression

extension Data {

}

extension String {
    func chunked(by length: Int) -> [String] {
        var chunks: [String] = []
        var index = startIndex
        while index < endIndex {
            let chunkEndIndex = self.index(index, offsetBy: length, limitedBy: endIndex) ?? endIndex
            let chunk = self[index..<chunkEndIndex]
            chunks.append(String(chunk))
            index = chunkEndIndex
        }
        return chunks
    }
}

class ViewController: UIViewController {
    
//    func compressData(_ data: Data) -> Data? {
//        var compressedData = Data(count: data.count)
//        let result = compressedData.withUnsafeMutableBytes { compressedBytes in
//            data.withUnsafeBytes { rawBytes in
//                if let sourceBuffer = rawBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
//                   let destinationBuffer = compressedBytes.bindMemory(to: UInt8.self).baseAddress {
//                    return compression_encode_buffer(destinationBuffer, compressedData.count, sourceBuffer, data.count, nil, COMPRESSION_LZMA)
//                }
//            }
//        }
//        if result != 0 {
//            // Create a new Data object from the compressed bytes
//            compressedData.count = result
//            let compressedCopy = Data(compressedData)
//            return compressedCopy
//        }
//        return nil
//    }

    func decompressData(_ compressedData: Data, uncompressedSize: Int) -> Data? {
        var decompressedData = Data(count: uncompressedSize)
        
        let result = compressedData.withUnsafeBytes { compressedBytes in
            decompressedData.withUnsafeMutableBytes { decompressedBytes in
                if let sourceBuffer = compressedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                   let destinationBuffer = decompressedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                    return compression_decode_buffer(destinationBuffer, uncompressedSize, sourceBuffer, compressedData.count, nil, COMPRESSION_LZMA)
                }
                return 0
            }
        }
        
        if result == 0 {
            return decompressedData
        } else if result == -1 {
            print("Decompression failed: Invalid input parameters")
        } else if result == -2 {
            print("Decompression failed: Insufficient buffer size")
        } else if result == -3 {
            print("Decompression failed: Unknown compression algorithm")
        } else if result == -4 {
            print("Decompression failed: Corrupted input data")
        } else {
            print("Decompression failed with error code: \(result)")
        }
        
        return nil
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qrCode = "000700009QADK99HI1H3NE0MM4QECRP0PCPNBBI3SIGMU9F25I2J4RIQ7EGTGFV15HSP8Q48DT14LEE2P1LPOR7Q2NDFCD6DC8ERJRSBCL2RVV4JUR0NKHO2K9F8O62N7SGL51T4AEM1U000"

        if let bitSequence = Base32hex.shared.base32HexToBinary(qrCode) {
            
            /// Base32Hex decoded string
            print("decoded string: \(bitSequence)")
            
            let sequenceNoHeader = "0000000001001110100101001101101000100101001100011001000001100010001110111011100000010110101100010011010011100110011011110010000011001011001100110111010110101110010000111110010010100001011011110010010111100010001011001000010100110010011011100101101000111011101000011101100000111111111000010010110001111001100101000110100010001000011011110100001001001010101110011100001011001000011010111001110001101100111110100001010111011010111101100011010011001101011000100001110110111001111011111000101101100101010001011011111111111100100100111111011011000001011110100100011100000010101000100101111010001100000110000101011100111111001000010101001010000111101001000101001110101100000111110000000000000000"
            
            let compressedData = stride(from: 0, to: sequenceNoHeader.count, by: 8).compactMap({ i -> UInt8? in
                let startIndex = sequenceNoHeader.index(sequenceNoHeader.startIndex, offsetBy: i)
                let endIndex = sequenceNoHeader.index(startIndex, offsetBy: 8, limitedBy: sequenceNoHeader.endIndex) ?? sequenceNoHeader.endIndex
                let binaryString = String(sequenceNoHeader[startIndex..<endIndex])
                return UInt8(strtoul(binaryString, nil, 2))
            })
            
            print("Compressed data: \(compressedData)")
            

           

//            let raw: Data! = String(repeating: "There is no place like 127.0.0.1", count: 25).data(using: .utf8)
//
//            print("raw   =>   \(raw.count) bytes")
//
//            for algo: Data.CompressionAlgorithm in [.zlib, .lzfse, .lz4, .lzma] {
//                let compressedData: Data! = raw.dec(withAlgorithm: algo)
//
//                let ratio = Double(raw.count) / Double(compressedData.count)
//                print("\(algo)   =>   \(compressedData.count) bytes, ratio: \(ratio)")
//
//                assert(compressedData.decompress(withAlgorithm: algo)! == raw)
//            }

        }

    }
    
}


// MARK: - LZMA

extension ViewController {
    
    struct LZMA {
        private static let dictionarySize = 1 << 17

        private static func lzmaDecompress(compressedData: [UInt8], outputSize: Int) -> [UInt8]? {
            var output = [UInt8]()
            var outputIndex = 0

            var position = 2 // Skip the 2-byte header
            var control = compressedData[position]
            position += 1

            var dictionary = [UInt8](repeating: 0, count: dictionarySize)
            var dictionaryPosition = dictionarySize - Int(compressedData[position]) - 1
            position += 1

            while outputIndex < outputSize && position < compressedData.count {
                if control & 1 != 0 {
                    let dictionaryOffset = dictionarySize - Int(compressedData[position]) - 1
                    position += 1

                    var length = Int(compressedData[position])
                    position += 1

                    for i in 0..<length {
                        guard dictionaryOffset + i < dictionary.count else {
                            return nil
                        }

                        let value = dictionary[dictionaryOffset + i]
                        output.append(value)
                        dictionary[dictionaryPosition] = value
                        dictionaryPosition += 1
                        dictionaryPosition %= dictionarySize
                    }

                    outputIndex += length
                } else {
                    guard position < compressedData.count else {
                        return nil
                    }

                    let value = compressedData[position]
                    output.append(value)
                    dictionary[dictionaryPosition] = value
                    position += 1
                    dictionaryPosition += 1
                    dictionaryPosition %= dictionarySize

                    outputIndex += 1
                }

                control >>= 1
                if control == 0 {
                    guard position < compressedData.count else {
                        return nil
                    }

                    control = compressedData[position]
                    position += 1
                }
            }

            return output
        }

        static func decompressLZMA(compressedData: [UInt8]) -> [UInt8]? {
            guard compressedData.count >= 2 else {
                return nil
            }

            let outputSize = Int(compressedData[0]) | (Int(compressedData[1]) << 8)
            return lzmaDecompress(compressedData: compressedData, outputSize: outputSize)
        }

        static func stringToUInt8Array(_ string: String) -> [UInt8] {
            return Array(string.utf8)
        }

            private static func lzmaCompress(inputData: [UInt8]) -> [UInt8]? {
                var compressedData = [UInt8]()

                // Append the decompressed data size as 2-byte little-endian header
                let outputSize = UInt16(inputData.count)
                compressedData.append(UInt8(outputSize & 0xFF))
                compressedData.append(UInt8((outputSize >> 8) & 0xFF))

                var position = 0
                var control = UInt8(0)
                var controlMask = UInt8(1)

                var dictionary = [UInt8](repeating: 0, count: dictionarySize)
                var dictionaryPosition = 0

                while position < inputData.count {
                    if controlMask == 0 {
                        compressedData.append(control)
                        control = 0
                        controlMask = 1
                    }

                    let currentByte = inputData[position]
                    let dictionaryOffset = dictionaryPosition >= dictionarySize ? dictionaryPosition - dictionarySize : dictionaryPosition

                    if dictionary[dictionaryOffset] == currentByte {
                        control |= controlMask
                        position += 1

                        var length = 1
                        while position < inputData.count && length < 255 && dictionary[(dictionaryOffset + length) % dictionarySize] == inputData[position] {
                            length += 1
                            position += 1
                        }

                        compressedData.append(UInt8(dictionaryPosition - dictionaryOffset))
                        compressedData.append(UInt8(length - 1))

                        for i in 0..<length {
                            let value = inputData[position - length + i]
                            dictionary[dictionaryPosition] = value
                            dictionaryPosition = (dictionaryPosition + 1) % dictionarySize
                        }
                    } else {
                        compressedData.append(currentByte)
                        dictionary[dictionaryPosition] = currentByte
                        dictionaryPosition = (dictionaryPosition + 1) % dictionarySize
                        position += 1
                    }

                    controlMask <<= 1
                }

                if controlMask > 1 {
                    compressedData.append(control)
                }

                return compressedData
            }

            static func compressLZMA(data: [UInt8]) -> [UInt8]? {
                return lzmaCompress(inputData: data)
            }

            static func compressLZMAToString(data: [UInt8]) -> String? {
                guard let compressedData = lzmaCompress(inputData: data) else {
                    return nil
                }
                
                return String(bytes: compressedData, encoding: .utf8)
            }
    }
    
}


extension ViewController: DecoderDelegate {
    
    func decoder(decoder: PLzmaSDK.Decoder, path: String, progress: Double) {
        print("decoder delegate path: \(path), progress: \(progress)")
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
            let endIndex = bitString.index(index, offsetBy: 5, limitedBy: bitString.endIndex) ?? bitString.endIndex
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
