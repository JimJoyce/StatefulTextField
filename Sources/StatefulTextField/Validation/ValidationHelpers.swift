//
//  ValidationHelpers.swift
//  MDRTAcademy
//
//  Created by Jim Joyce on 8/2/19.
//  Copyright © 2019 Jim Joyce. All rights reserved.
//

import Foundation

public enum PresetValidation {
    case required
    case notEmpty
    case email
    case password
    case matches(String)
    case minLength(Int)
    case maxLength(Int)
    case between(Int, Int)
    case greaterThan(Int)
    case lessThan(Int)

    func run<T>(value: T) -> (passes: Bool, val: Any?) {
        guard let val = value as? String else { return (passes: false, val: value) }
        switch self {
        case .required, .notEmpty:
            return (passes: NotEmptyValidator.run(val), nil)
        case .email:
            return (passes: EmailValidator(val).run(), nil)
        case .minLength(let length):
            return (passes: val.count >= length, nil)
        case .matches(let compareStr):
            return (passes: val == compareStr, nil)
        case .password:
            return (passes: PasswordFormatValidator(val).run(), nil)
        case .maxLength(let length):
            return (passes: val.count <= length, nil)
        case .between(let min, let max):
            guard let intVal = Int(val) else { return (passes: false, nil) }
            let passes: Bool = intVal >= min && intVal <= max
            return (passes: passes, nil)
        case .greaterThan(let int):
            guard let intVal = Int(val) else { return (passes: false, nil) }
            let passes: Bool = intVal > int
            return (passes: passes, nil)
        case .lessThan(let int):
            guard let intVal = Int(val) else { return (passes: false, nil) }
            let passes: Bool = intVal < int
            return (passes: passes, intVal)
        }
    }
}

struct ValidatedProp<T> {
    enum ValidStates {
        case untouched, touched, active, error, valid
    }

    var validations: [PresetValidation] = []
    var state: ValidStates = .untouched
    var isValid: Bindable<Bool>? = Bindable<Bool>(false)

    var value: T {
        didSet {
            guard validate() == true else { state = .error; return }
            state = .valid
        }
    }

    init(val: T, withValidations v: PresetValidation...) {
        value = val
        validations = v
    }

    func validate() -> Bool {
        let ranValidations = validations.map { (validation) in
            return validation.run(value: value)
        }

        return !ranValidations.map { $0.passes }.contains(false)
    }
}

typealias Validation = PresetValidation
