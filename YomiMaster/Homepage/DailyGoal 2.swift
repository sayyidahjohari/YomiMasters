import SwiftUI

struct DailyGoal: Identifiable {
    let id = UUID()
    let title: String    // Fixed text, e.g. "Read Book"
    var targetNumber: Int
    var isCompleted: Bool = false
}

class DailyGoalsViewModel: ObservableObject {
    @Published var goals: [DailyGoal] = [
        DailyGoal(title: "Read Book", targetNumber: 1),
        DailyGoal(title: "Review Flashcards", targetNumber: 10)
    ]
}

struct DailyGoalsView: View {
    @ObservedObject var viewModel: DailyGoalsViewModel
    
    @State private var editingGoalID: UUID? = nil
    @State private var editNumberText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Today's Goal")
                .font(.title2)
                .bold()
                .padding(.bottom, 10)
            
            ForEach($viewModel.goals) { $goal in
                HStack {
                    // Checkbox toggle
                    Button(action: {
                        goal.isCompleted.toggle()
                    }) {
                        Image(systemName: goal.isCompleted ? "checkmark.square.fill" : "square")
                            .foregroundColor(goal.isCompleted ? .green : .gray)
                            .font(.title2)
                    }
                    
                    Text(goal.title)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    if editingGoalID == goal.id {
                        TextField("Number", text: $editNumberText)
                            .keyboardType(.numberPad)
                            .frame(width: 40)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Save") {
                            if let newNumber = Int(editNumberText), newNumber > 0 {
                                goal.targetNumber = newNumber
                            }
                            editingGoalID = nil
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    } else {
                        Text("\(goal.targetNumber)")
                            .frame(width: 40)
                        
                        Button(action: {
                            editingGoalID = goal.id
                            editNumberText = "\(goal.targetNumber)"
                        }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}
