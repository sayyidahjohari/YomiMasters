import SwiftUI

struct DailyGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    var targetNumber: Int
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, targetNumber: Int, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.targetNumber = targetNumber
        self.isCompleted = isCompleted
    }
}



struct DailyGoalsView: View {
    @ObservedObject var viewModel: DailyGoalsViewModel
    @State private var editingGoalID: UUID? = nil
    @State private var editNumberText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Today's Goals")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            ForEach($viewModel.goals) { $goal in
                VStack {
                    HStack(alignment: .center) {
                        Button(action: {
                            goal.isCompleted.toggle()
                            viewModel.saveGoals()
                        }) {
                            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(goal.isCompleted ? .green : .gray)
                                .font(.title)
                        }
                        
                        if editingGoalID == goal.id {
                            Text("\(goal.title)")
                                .font(.title3)
                                .foregroundColor(.black)
                            
                            TextField("Number", text: $editNumberText)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(goal.title.lowercased().contains("flashcard") ? "flashcards" : "book")
                                .font(.title3)
                            
                            Button("Save") {
                                if let newNumber = Int(editNumberText), newNumber > 0 {
                                    goal.targetNumber = newNumber
                                    viewModel.saveGoals()
                                }
                                editingGoalID = nil
                            }
                            .font(.caption)
                        } else {
                            Text(buildGoalText(for: goal))
                                .font(.title3)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    editingGoalID = goal.id
                                    editNumberText = "\(goal.targetNumber)"
                                }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient.dustyRoseGradient)
        .cornerRadius(25)
        .shadow(radius: 5)
        .padding()
    }

    func buildGoalText(for goal: DailyGoal) -> AttributedString {
        var str = AttributedString("\(goal.title) \(goal.targetNumber) \(goal.title.lowercased().contains("flashcard") ? "flashcards" : "book")")
        
        if let numberRange = str.range(of: "\(goal.targetNumber)") {
            str[numberRange].foregroundColor = .blue
            str[numberRange].font = .title3.bold()
        }
        return str
    }
}
#Preview {
    DailyGoalsView(viewModel: DailyGoalsViewModel())
}
