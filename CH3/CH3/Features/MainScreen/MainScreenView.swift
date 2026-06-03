//
//  MainScreenView.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 04/06/26.
//

import SwiftUI

struct MainScreenView: View {
    @State private var currentInput = 0
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(role:.destructive) {
                        
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    Picker("What is your favorite color?", selection: $currentInput) {
                        Text("Type").tag(0)
                        Text("Listen").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                Spacer()
                if (currentInput == 0) {
                    AudioInputView()
                } else {
                    TextInputView()
                }
            }.padding(20)
        }
    }
}

#Preview {
    MainScreenView()
}
