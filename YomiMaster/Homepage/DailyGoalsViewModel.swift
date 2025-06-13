//
//  DailyGoalsViewModel.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 03/06/2025.
//


import Foundation

class DailyGoalsViewModel: ObservableObject {
    @Published var goals: [DailyGoal] = []

    private let goalsKey = "dailyGoals"
    private let lastOpenedKey = "lastOpenedDate"

    init() {
        loadGoals()
    }

    func loadGoals() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastOpened = UserDefaults.standard.object(forKey: lastOpenedKey) as? Date

        if let lastOpened = lastOpened, Calendar.current.isDate(today, inSameDayAs: lastOpened) {
            // Same day → Load saved goals
            if let data = UserDefaults.standard.data(forKey: goalsKey),
               let savedGoals = try? JSONDecoder().decode([DailyGoal].self, from: data) {
                self.goals = savedGoals
                return
            }
        }

        // New day or no saved goals → Reset to default
        self.goals = [
            DailyGoal(title: "Read", targetNumber: 1),
            DailyGoal(title: "Review", targetNumber: 10)
        ]
        saveGoals()
        UserDefaults.standard.set(today, forKey: lastOpenedKey)
    }

    func saveGoals() {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: goalsKey)
        }
    }
}
