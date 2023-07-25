//
//  String_ext.swift
//  WordPin
//
//  Created by Yida Zhang on 7/23/23.
//

import Foundation

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
