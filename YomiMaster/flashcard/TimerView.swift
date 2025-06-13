//
//  TimerView.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 24/05/2025.
//


import SwiftUI

struct TimerView: View {
    @Binding var timerValue: Int
    @Binding var timerRunning: Bool

    var body: some View {
        Text("⏱ \(timerValue)s")
            .font(.headline)
            .foregroundColor(.black)
            .padding(8)
            .background(Color.white.opacity(0.8))
            .clipShape(Capsule())
            .onAppear {
                startTimer()
            }
    }

    func startTimer() {
        if timerRunning { return }

        timerRunning = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timer.invalidate()
                timerRunning = false
            }
        }
    }
}
