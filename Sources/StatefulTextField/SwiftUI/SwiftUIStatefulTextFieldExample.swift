//
//  SwiftUIStatefulTextFieldExample.swift
//
//
//  Created by Andrew Stamm on 7/15/24.
//

import SwiftUI

private struct SwiftUIStatefulTextFieldExample: View {
    var placeholder1: String? = "andrewemail.com"
    var placeholder2: String? = "tooshort"

    var body: some View {
        ZStack {
            Color
                .gray
                .opacity(0.45)
                .edgesIgnoringSafeArea(.all
                )

            VStack(spacing: 60) {
                VStack {
                    HStack {
                        SwiftUIStatefulTextField()
                    }
                    .padding(12)
                }
                .background(Color.white)
                .padding(.horizontal, 44)
                .frame(width: .infinity, height: 50)

                VStack {
                    HStack {
                        SwiftUIStatefulTextField(
                            text: placeholder1,
                            validators: [.email]
                        )
                    }
                    .padding(12)
                }
                .background(Color.white)
                .padding(.horizontal, 44)
                .frame(width: .infinity, height: 50)

                VStack {
                    HStack {
                        SwiftUIStatefulTextField(
                            text: placeholder2,
                            validators: [.greaterThan(20)]
                        )
                    }
                    .padding(12)
                }
                .background(Color.white)
                .padding(.horizontal, 44)
                .frame(width: .infinity, height: 50)
            }
        }
    }
}

#Preview {
    SwiftUIStatefulTextFieldExample()
}
