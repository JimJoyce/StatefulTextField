//
//  Formatters.swift
//  MDRTAcademy
//
//  Created by Jim Joyce on 8/2/19.
//  Copyright © 2019 Jim Joyce. All rights reserved.
//

enum StringFormatters: String {
    case phone = "(###) ###-####"
    case dob = "##/##/####"
    case creditCard = "#### #### #### ####"

    var replacementChar: String {
        return "#"
    }

    var invalidCharacters: String {
        switch self {
        case .phone, .dob, .creditCard:
            return "[^0-9]"
        }
    }

    func cleanedString(_ str: String) -> String {
        return str.replacingOccurrences(of: invalidCharacters,
                                        with: "",
                                        options: .regularExpression,
                                        range: str.startIndex..<str.endIndex)
    }

    func format(_ string: String) -> String {
        var string = cleanedString(string)
        let maskPattern = rawValue
        let final = maskPattern.reduce(into: "") { (result, char) in
            guard !string.isEmpty else { return }
            guard char == self.replacementChar.first! else {
                result.append(char)
                return
            }

            result.append(string.removeFirst())
        }

        return final
    }
}
