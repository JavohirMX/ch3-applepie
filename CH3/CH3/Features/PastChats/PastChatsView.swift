//
//  PastChatsView.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 03/06/26.
//

import SwiftUI

struct PastChatsView: View {
    var body: some View {
        ZStack{
            VStack() {
//                HStack() {
//                    Spacer()
//                    
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 21))
//                            .frame(width: 32, height: 32)
//                    }
//                    .buttonStyle(.bordered)
//                    .buttonBorderShape(.circle)
//                }.padding(.horizontal, 20)
                List(){
                    Button(){
                        
                    } label : {
                        Label("Create New Chat", systemImage: "plus")
                    }
                    Button(){
                        
                    } label : {
                        Label("Search Chat", systemImage: "magnifyingglass")
                    }
                    Section(header: Text("Pinned Info")){
                        Text("The network is 'Guest_Net' and the password is 'travel2026'.")
                        Text("Take the Blue Line train towards Downtown, then transfer at Central Station to the Red Line.")
                    }
                    
                    Section(header: Text("Recent Chats")){
                        Text("Bali Road Trip")
                        Text("Taxi Fare to Central Station")
                        Text("Directions to the National Museum")
                        Text("Booking Tomorrow's Boat Tour")
                        Text("Cafe Barista - Wi-Fi & Coffee Order")
                    }
                }
            }
        }.background(Color(.systemGray6).ignoresSafeArea())
    }
}

#Preview {
    PastChatsView()
}
