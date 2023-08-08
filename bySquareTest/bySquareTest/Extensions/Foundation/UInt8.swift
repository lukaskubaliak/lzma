//
//  Data.swift
//  bySquareTest
//
//  Created by Lukáš Kubaliak on 29/06/2023.
//

import Foundation

extension [UInt8] {
    
    func toString() -> String? {
        self.isEmpty
        ? "nil"
        : String(bytes: self, encoding: .utf8) ?? ""
    }
    
//    func toInt() -> Int? {
//        self.isEmpty
//        ? -0
//        : Int(self.reduce(0) { $0 * 10 + ($1 - 48) })
//    }
    
}
