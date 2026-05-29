import SwiftUI

struct RecentChatsListView: View {
    @Environment(ChatStore.self) private var chatStore
    @Binding var path: [AppRoute]

    let category: CategoryType

    @State private var searchText = ""

    private var theme: CategoryTheme {
        CategoryTheme.theme(for: category)
    }

    private var chats: [RecentChat] {
        chatStore.chats(for: category)
    }

    private var filteredChats: [RecentChat] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return chats }
        let lowered = query.lowercased()
        return chats.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.subtitle.lowercased().contains(lowered) ||
            $0.dateText.lowercased().contains(lowered)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(theme.listSubtitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.bottom, 4)

                if filteredChats.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredChats) { chat in
                        NavigationLink(value: AppRoute.transcript(chat)) {
                            RecentChatRowView(chat: chat)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
//        .toolbarBackground(AppColors.background, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
        .searchable(text: $searchText, prompt: "Search")
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button(action: startNewChat) {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("New conversation")
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            if searchText.isEmpty {
                Text("No conversations yet")
                    .font(AppTypography.listTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Tap the compose button below to create a new conversation.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text("No results")
                    .font(AppTypography.listTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Try a different search term.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 24)
    }

    private func startNewChat() {
        switch category {
        case .transport:
            path.append(.transportModePicker)
        case .hotel:
            path.append(.contextForm(.hotel))
        case .store:
            path.append(.contextForm(.store))
        case .misc:
            path.append(.contextForm(.miscGeneric))
        }
    }
}
