import SwiftUI

// New Progress Tracker View
struct DeckDetailView: View {
    var deck: Deck
    
    // Simulated data for the progress (3 months, each with 30 days)
    let progressData: [[[Bool]]] = [
        // January
        Array(repeating: Array(repeating: false, count: 7), count: 5), // 5 weeks (rows) for 7 days in each week
        // February
        Array(repeating: Array(repeating: false, count: 7), count: 5),
        // March
        Array(repeating: Array(repeating: false, count: 7), count: 5)
    ]
    
    var body: some View {
        VStack {
            Text(deck.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("New: \(deck.newCards)")
                    Text("Learning: \(deck.learningCards)")
                    Text("Due: \(deck.dueCards)")
                }
                Spacer()
            }
            .padding()
            
            // Progress Tracker Section
            Text("Progress")
                .font(.headline)
                .padding(.top, 20)
            
            // Progress for each month
            ForEach(0..<progressData.count, id: \.self) { monthIndex in
                ProgressSection(title: self.monthName(for: monthIndex), progressData: progressData[monthIndex])
            }
            
            Spacer()
            
        }
        .navigationBarTitle(Text(deck.name), displayMode: .inline)
        .padding()
    }
    
    // Helper function to get month name based on index
    func monthName(for index: Int) -> String {
        switch index {
        case 0:
            return "January"
        case 1:
            return "February"
        case 2:
            return "March"
        default:
            return ""
        }
    }
}

// Progress Section View for each Month
struct ProgressSection: View {
    var title: String
    var progressData: [[Bool]]
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top, 10)
            
            // Days of the week header
            HStack {
                Text("M").frame(width: 30)
                Text("T").frame(width: 30)
                Text("W").frame(width: 30)
                Text("T").frame(width: 30)
                Text("F").frame(width: 30)
                Text("S").frame(width: 30)
                Text("S").frame(width: 30)
            }
            .font(.caption)
            .padding(.top, 5)
            
            // 5 rows for each month (max 31 days, split across 5 weeks)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(30)), count: 7), spacing: 10) {
                ForEach(0..<5, id: \.self) { weekIndex in
                    HStack {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let day = weekIndex * 7 + dayIndex
                            if day < progressData.count {
                                Rectangle()
                                    .fill(progressData[weekIndex][dayIndex] ? Color.green : Color.gray.opacity(0.3))
                                    .frame(height: 30)
                                    .cornerRadius(4)
                                    .padding(2)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}
