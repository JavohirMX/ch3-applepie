//
//  TextSheet.swift
//  conversa
//
//  Created by Javohir Muhammad on 04/06/26.
//

import SwiftUI

struct TextSheet: View {
    @Binding var draftText: String
    @Binding var selectedDetent: PresentationDetent
    @State private var shouldFocusEditorAfterExpand = false
    @State private var isComposerExpanded = false
    @State private var showFlipText = false
    @FocusState private var isEditorFocused: Bool

    private var canFlipText: Bool {
        !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var usesCompactComposer: Bool {
        !isComposerExpanded && draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        draftText: Binding<String>,
        selectedDetent: Binding<PresentationDetent>
    ) {
        _draftText = draftText
        _selectedDetent = selectedDetent
    }

    private static let suggestions = [
        "Hi there, my name is Leo and I am deaf. I use this app to communicate with you.",
        "I need help finding gate 5.",
        "I need help finding the toilet.",
    ]

    private static let mediumSuggestions = Array(suggestions.prefix(2))

    private var isPeekDetent: Bool {
        selectedDetent == .fraction(0.1)
    }

    private var isMediumDetent: Bool {
        selectedDetent == .fraction(0.5)
    }

    var body: some View {
        Group {
            if isPeekDetent {
                peekContent
            } else if isMediumDetent {
                mediumContent
            } else {
                expandedContent
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .animation(.easeInOut(duration: 0.25), value: selectedDetent)
        .animation(.easeInOut(duration: 0.25), value: usesCompactComposer)
        .onAppear {
            if canFlipText {
                isComposerExpanded = true
            }
        }
        .onChange(of: selectedDetent) { _, detent in
            guard detent == .large, shouldFocusEditorAfterExpand else { return }
            shouldFocusEditorAfterExpand = false
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(350))
                isEditorFocused = true
            }
        }
        .fullScreenCover(isPresented: $showFlipText) {
            FlipTextView(text: draftText) {
                showFlipText = false
            }
        }
    }

    // MARK: - Peek (0.1)

    private var peekContent: some View {
        Text("Write your thoughts")
            .font(Typography.sheetTitle)
            .foregroundStyle(BrandColors.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }

    // MARK: - Medium (0.5)

    private var mediumContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            sheetTitle

            compactTextFieldSection(action: expandAndFocusEditor)

            VStack(spacing: 10) {
                ForEach(Self.mediumSuggestions, id: \.self) { suggestion in
                    SuggestionBubbleView(text: suggestion, style: .compact) {
                        selectSuggestion(suggestion)
                    }
                }
            }

            Button("See more", action: expandSheet)
                .font(Typography.suggestionBody)
                .foregroundStyle(BrandColors.navy)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("See more suggestions")
        }
    }

    // MARK: - Expanded (large)

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sheetTitle

            if usesCompactComposer {
                compactTextFieldSection(action: { expandComposer(focus: true) })
            } else {
                textEditorSection
                actionButtonsRow
            }

            Text("Suggestions")
                .font(Typography.suggestionLabel)
                .foregroundStyle(BrandColors.suggestionLabel)
                .onTapGesture(perform: dismissKeyboard)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Self.suggestions, id: \.self) { suggestion in
                        SuggestionBubbleView(text: suggestion, style: .standard) {
                            selectSuggestion(suggestion)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private var sheetTitle: some View {
        Text("Write your thoughts")
            .font(Typography.sheetTitle)
            .foregroundStyle(BrandColors.navy)
            .frame(maxWidth: .infinity)
            .onTapGesture(perform: dismissKeyboard)
    }

    private func compactTextFieldSection(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(BrandColors.editorBackground)

                Group {
                    if draftText.isEmpty {
                        Text("Type your own...")
                            .foregroundStyle(BrandColors.editorPlaceholder)
                    } else {
                        Text(draftText)
                            .foregroundStyle(BrandColors.navy)
                            .lineLimit(1)
                    }
                }
                .font(Typography.body)
                .padding(.horizontal, 16)
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Your message")
        .accessibilityHint("Opens expanded editor")
    }

    private var textEditorSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(BrandColors.editorBackground)

                FittingTextEditor(
                    text: $draftText,
                    focus: $isEditorFocused,
                    availableSize: geometry.size
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minHeight: 200)
    }

    private var actionButtonsRow: some View {
        HStack {
            actionButton(icon: "xmark", label: "Clear text", action: clearDraft)

            Spacer()

            actionButton(
                icon: "arrow.up.arrow.down",
                label: "Flip text display",
                isEnabled: canFlipText
            ) {
                presentFlipText()
            }
        }
    }

    private func actionButton(
        icon: String,
        label: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(BrandColors.navy)
                .frame(width: 44, height: 44)
                .background(BrandColors.actionButtonBackground, in: Circle())
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
        .accessibilityLabel(label)
    }

    private func dismissKeyboard() {
        isEditorFocused = false
        Keyboard.dismiss()
    }

    private func presentFlipText() {
        guard canFlipText else { return }
        dismissKeyboard()
        showFlipText = true
    }

    private func clearDraft() {
        draftText = ""
        isComposerExpanded = false
        dismissKeyboard()
    }

    private func selectSuggestion(_ text: String) {
        dismissKeyboard()
        draftText = text
        isComposerExpanded = true
        if isMediumDetent {
            expandToLarge(focusEditor: false)
        }
    }

    private func expandSheet() {
        expandToLarge(focusEditor: false)
    }

    private func expandAndFocusEditor() {
        expandToLarge(focusEditor: true)
    }

    private func expandComposer(focus: Bool) {
        isComposerExpanded = true
        guard focus else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            isEditorFocused = true
        }
    }

    private func expandToLarge(focusEditor: Bool) {
        guard !isPeekDetent else { return }
        if selectedDetent == .large {
            if focusEditor {
                expandComposer(focus: true)
            }
            return
        }
        if focusEditor {
            isComposerExpanded = true
        }
        shouldFocusEditorAfterExpand = focusEditor
        selectedDetent = .large
    }
}

#Preview("Medium 0.5") {
    @Previewable @State var detent: PresentationDetent = .fraction(0.5)
    @Previewable @State var draft = ""
    TextSheet(draftText: $draft, selectedDetent: $detent)
}

#Preview("Expanded compact") {
    @Previewable @State var detent: PresentationDetent = .large
    @Previewable @State var draft = ""
    TextSheet(draftText: $draft, selectedDetent: $detent)
}

#Preview("Expanded filled") {
    @Previewable @State var detent: PresentationDetent = .large
    @Previewable @State var draft =
        "Hi there, my name is Leo and I am deaf. I use this app to communicate with you."
    TextSheet(draftText: $draft, selectedDetent: $detent)
}
