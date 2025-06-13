//
//  OptionButtonStyle.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 24/05/2025.
//


import SwiftUI

struct OptionButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(configuration.isPressed ? 0.5 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
