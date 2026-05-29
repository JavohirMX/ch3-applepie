import SwiftUI

struct CategoryContextFormView: View {
    @Environment(ChatStore.self) private var chatStore
    @Binding var path: [AppRoute]

    let formType: ContextFormType

    @State private var stepIndex = 0
    @State private var answers: [String] = []
    @State private var currentAnswer = ""
    @State private var checkInDate = Date()
    @State private var checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var showAIModal = false
    @State private var pendingChat: RecentChat?

    private var definition: ContextFormDefinition {
        ContextFormMockData.definition(for: formType)
    }

    private var theme: CategoryTheme {
        CategoryTheme.theme(for: CategoryTheme.category(for: formType))
    }

    private var currentStep: ContextFormStep? {
        guard stepIndex < definition.steps.count else { return nil }
        return definition.steps[stepIndex]
    }

    var body: some View {
        ZStack {
            theme.primary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                if let step = currentStep {
                    VStack(spacing: 20) {
                        Image(systemName: formType.iconSystemName)
                            .font(.system(size: 56, weight: .regular))
                            .foregroundStyle(.white.opacity(0.9))

                        Text(step.prompt)
                            .font(AppTypography.formPrompt)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }

                Spacer()

                bottomInput
            }

            if showAIModal, let pendingChat {
                AILearnedModalView(theme: theme) {
                    chatStore.add(pendingChat)
                    showAIModal = false
                    path.removeLast()
                    if case .transportModePicker = path.last {
                        path.removeLast()
                    }
                    path.append(.transcript(pendingChat))
                }
            }
        }
        .navigationTitle(formType.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip", action: finishForm)
            }
        }
        .toolbarBackground(theme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if answers.isEmpty {
                answers = Array(repeating: "", count: definition.steps.count)
                currentAnswer = ""
            }
        }
        .onChange(of: stepIndex) { _, newIndex in
            if newIndex < answers.count {
                currentAnswer = answers[newIndex]
                if currentStep?.inputKind == .dateRange, currentAnswer.isEmpty {
                    syncDateRangeAnswer()
                }
            }
        }
    }

    private var bottomInput: some View {
        VStack(spacing: 12) {
            if let step = currentStep {
                formInput(for: step)
                    .padding(.horizontal, 16)
            }

            Button(action: advanceStep) {
                Text(stepIndex >= definition.steps.count - 1 ? "Done" : "Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.white, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private func formInput(for step: ContextFormStep) -> some View {
        switch step.inputKind {
        case .text:
            FormGlassTextField(
                placeholder: step.placeholder,
                text: $currentAnswer,
                multiline: isMultilineStep(step),
                onSubmit: advanceStep
            )
        case .yesNo:
            FormGlassYesNoPicker(selection: $currentAnswer)
        case .dateRange:
            FormGlassDateRangeField(checkIn: $checkInDate, checkOut: $checkOutDate)
                .onChange(of: checkInDate) { _, _ in syncDateRangeAnswer() }
                .onChange(of: checkOutDate) { _, _ in syncDateRangeAnswer() }
                .onAppear { syncDateRangeAnswer() }
        }
    }

    private func isMultilineStep(_ step: ContextFormStep) -> Bool {
        let prompt = step.prompt.lowercased()
        return prompt.contains("anything") || prompt.contains("communicate") || prompt.contains("remember")
    }

    private func syncDateRangeAnswer() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        currentAnswer = "\(formatter.string(from: checkInDate)) – \(formatter.string(from: checkOutDate))"
    }

    private func advanceStep() {
        saveCurrentAnswer()

        if stepIndex >= definition.steps.count - 1 {
            finishForm()
            return
        }

        stepIndex += 1
        currentAnswer = answers[stepIndex]
    }

    private func saveCurrentAnswer() {
        guard stepIndex < answers.count else { return }
        answers[stepIndex] = currentAnswer
    }

    private func finishForm() {
        saveCurrentAnswer()
        let session = ContextFormSession(formType: formType, answers: answers)
        pendingChat = session.makeRecentChat()
        showAIModal = true
    }
}
