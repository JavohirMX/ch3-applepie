import SwiftUI

struct CategoryContextFormView: View {
    @Environment(ChatStore.self) private var chatStore
    @Binding var path: [AppRoute]

    let formType: ContextFormType

    // MARK: - Form state

    @State private var stepIndex = 0
    @State private var answers: [String] = []
    @State private var currentAnswer = ""
    @State private var checkInDate = Date()
    @State private var checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    // MARK: - Loading & modal state

    @State private var formDefinition: ContextFormDefinition?
    @State private var isLoadingForm = false
    @State private var formError: String?
    @State private var isCreating = false
    @State private var createError: String?
    @State private var showAIModal = false
    @State private var pendingChat: RecentChat?

    // MARK: - Derived

    private var theme: CategoryTheme {
        CategoryTheme.theme(for: CategoryTheme.category(for: formType))
    }

    private var currentStep: ContextFormStep? {
        guard let definition = formDefinition, stepIndex < definition.steps.count else { return nil }
        return definition.steps[stepIndex]
    }

    private var stepCount: Int {
        formDefinition?.steps.count ?? 0
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            theme.primary.ignoresSafeArea()

            if isLoadingForm {
                ProgressView()
                    .tint(.white)
            } else if formError != nil {
                errorState
            } else if formDefinition != nil {
                formContent
            }

            if showAIModal, let pendingChat {
                AILearnedModalView(theme: theme) {
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
                    .disabled(isCreating)
            }
        }
        .toolbarBackground(theme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await loadFormDefinition()
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

    // MARK: - Form content

    private var formContent: some View {
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
    }

    private var errorState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.7))
            Text(formError ?? "Failed to load form")
                .font(AppTypography.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await loadFormDefinition() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom input

    private var bottomInput: some View {
        VStack(spacing: 12) {
            if createError != nil {
                Text(createError!)
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            if let step = currentStep {
                formInput(for: step)
                    .padding(.horizontal, 16)
                    .disabled(isCreating)
            }

            Button(action: advanceStep) {
                if isCreating {
                    ProgressView()
                        .tint(theme.primary)
                } else {
                    Text(stepIndex >= stepCount - 1 ? "Done" : "Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(.white, in: Capsule())
            .disabled(isCreating || formDefinition == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 12)
    }

    // MARK: - Form input switch

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

    // MARK: - Helpers

    private func isMultilineStep(_ step: ContextFormStep) -> Bool {
        let prompt = step.prompt.lowercased()
        return prompt.contains("anything") || prompt.contains("communicate") || prompt.contains("remember")
    }

    private func syncDateRangeAnswer() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        currentAnswer = "\(formatter.string(from: checkInDate)) – \(formatter.string(from: checkOutDate))"
    }

    private func saveCurrentAnswer() {
        guard stepIndex < answers.count else { return }
        answers[stepIndex] = currentAnswer
    }

    // MARK: - Load form definition from backend

    private func loadFormDefinition() async {
        isLoadingForm = true
        formError = nil

        do {
            let response = try await FormService.shared.getFormDefinition(formType: formType.apiValue)
            formDefinition = ContextFormDefinition(from: response)
            // Initialize answers array if not already done
            if answers.isEmpty {
                answers = Array(repeating: "", count: formDefinition?.steps.count ?? 0)
                currentAnswer = ""
            }
        } catch {
            formError = error.localizedDescription
        }

        isLoadingForm = false
    }

    // MARK: - Navigation

    private func advanceStep() {
        saveCurrentAnswer()

        if stepIndex >= stepCount - 1 {
            finishForm()
            return
        }

        stepIndex += 1
        currentAnswer = answers[stepIndex]
    }

    private func finishForm() {
        saveCurrentAnswer()
        createError = nil

        Task {
            await createChatOnBackend()
        }
    }

    /// Create the chat on the backend, then show the "AI learned" modal.
    private func createChatOnBackend() async {
        isCreating = true
        createError = nil

        let category = CategoryTheme.category(for: formType)
        let session = ContextFormSession(formType: formType, answers: answers)
        let localPreview = session.makeRecentChat()

        // Build context_answers as string-keyed dict: {"0": "answer0", "1": "answer1", ...}
        let contextAnswers = Dictionary(
            uniqueKeysWithValues: answers.enumerated().map { (String($0.0), $0.1) }
        )

        do {
            let chat = try await chatStore.createChat(
                category: category,
                formType: formType,
                title: localPreview.title,
                subtitle: localPreview.subtitle,
                countryCode: localPreview.countryCode,
                contextAnswers: contextAnswers
            )
            pendingChat = chat
            showAIModal = true
        } catch {
            createError = error.localizedDescription
        }

        isCreating = false
    }
}

// MARK: - Backend DTO → local model mapping

extension ContextFormDefinition {
    init(from response: FormDefinitionResponse) {
        let steps = response.steps.map { step in
            let inputKind: ContextInputKind = switch step.inputKind {
            case "yes_no": .yesNo
            case "date_range": .dateRange
            default: .text
            }
            return ContextFormStep(prompt: step.prompt, inputKind: inputKind, placeholder: step.placeholder)
        }
        // Map the backend form_type string back to the local enum
        let formType = ContextFormType(fromApiValue: response.formType)
        self.init(formType: formType, steps: steps)
    }
}

extension ContextFormType {
    init(fromApiValue value: String) {
        switch value {
        case "airport": self = .airport
        case "cab": self = .cab
        case "bus": self = .bus
        case "hotel": self = .hotel
        case "store": self = .store
        case "misc_generic": self = .miscGeneric
        default: self = .miscGeneric
        }
    }
}
