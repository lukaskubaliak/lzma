//
//  String.swift
//  bySquareTest
//
//  Created by Lukáš Kubaliak on 10/06/2023.
//

//import Foundation
extension String {
    
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
    
}
