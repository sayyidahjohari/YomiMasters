//
//  FrameReader.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 01/06/2025.
//


import SwiftUI

struct FrameReader: UIViewRepresentable {
    @Binding var frame: CGRect

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            self.frame = view.superview?.convert(view.frame, to: nil) ?? .zero
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.frame = uiView.superview?.convert(uiView.frame, to: nil) ?? .zero
        }
    }
}
