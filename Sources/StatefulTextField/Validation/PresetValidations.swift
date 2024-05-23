//
//  PresetValidations.swift
//  MDRTAcademy
//
//  Created by Jim Joyce on 8/2/19.
//  Copyright © 2019 Jim Joyce. All rights reserved.
//

import Foundation

public protocol Validator {
    var name: String! { get set }
    associatedtype InputValueType
    typealias ConfigurationBlock<V:Validator> = ((_: V) -> V)
    static func run(_ value: InputValueType?) -> Bool
    var value: InputValueType? { get set }
    func run() -> Bool
}

struct NotEmptyValidator: Validator {
    var value: String?
    init(_ val: InputValueType) {
        value = val
    }

    func run() -> Bool {
        guard let nonNilValue = value else { return false }
        return nonNilValue.count != 0
    }

    typealias InputValueType = String
    var name: String! = "Not Empty"

    static func run(_ value: InputValueType?) -> Bool {
        guard let nonNilValue = value else { return false }
        return nonNilValue.count != 0
    }
}

protocol RegexMatchValidator: Validator {
    var matchPattern: String { get }
}

extension RegexMatchValidator {
    func run() -> Bool {
        let str = value as? String ?? ""
        let regxp = try! NSRegularExpression(pattern: matchPattern, options: .caseInsensitive)
        return regxp.numberOfMatches(in: str, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: str.count)) > 0
    }
}

struct EmailValidator: RegexMatchValidator {
    typealias InputValueType = String
    static let matchPattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let matchPattern: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    var value: InputValueType?
    var name: String! = "Not Empty"

    init(_ val: InputValueType?) {
        value = val
    }

    static func run(_ value: InputValueType?) -> Bool {
        let str = NSString(string: value ?? "")
        let pred = NSPredicate(format: "SELF MATCHES %@", matchPattern)
        return pred.evaluate(with: str)
    }
}

struct PasswordFormatValidator: RegexMatchValidator {
    var name: String! = "Password format"
    typealias InputValueType = String
    var value: String?
    static let matchPattern: String = "(?=\\S+\\d)(\\S){6,}"
    var matchPattern: String = "(?=\\S+\\d)(\\S){6,}"

    init(_ val: InputValueType?) {
        value = val
    }

    static func run(_ value: String?) -> Bool {
        let str = NSString(string: value ?? "")
        let pred = NSPredicate(format: "SELF MATCHES %@", matchPattern)
        return pred.evaluate(with: str)
    }
}
