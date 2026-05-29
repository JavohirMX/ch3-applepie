//
//  ContentView.swift
//  CH3
//
//  Created by Javohir Muhammad on 28/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var path: [AppRoute] = []
    @State private var chatStore = ChatStore()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(categories: AppMockData.categories)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .recentChats(let category):
                        RecentChatsListView(path: $path, category: category)
                    case .transportModePicker:
                        TransportModePickerView(path: $path)
                    case .contextForm(let formType):
                        CategoryContextFormView(path: $path, formType: formType)
                    case .transcript(let chat):
                        ConversationView(chat: chat)
                    }
                }
        }
        .environment(chatStore)
    }
}

#Preview {
    ContentView()
}
