//
//  SwiftUIStatefulTextField.swift
//
//
//  Created by Andrew Stamm on 7/15/24.
//

#if canImport(UIKit) && canImport(SwiftUI)

import UIKit
import SwiftUI

struct SwiftUIStatefulTextField: UIViewRepresentable {
    var text: String?
    var validators: [PresetValidation] = []

    func makeUIView(context: Context) -> StatefulTextField {
        return StatefulTextField()
    }

    func updateUIView(_ uiView: StatefulTextField, context: Context) {
        uiView.text = text
        uiView.validators = validators
    }
}

#endif
