//
//  TextInput.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 04/06/26.
//

import SwiftUI

struct TextInputView: View {
    @State var userText = ""
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                VStack{
                    Text("Tap below to start typing")
                    TextEditor(text: $userText)
                        .font(.title)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.bottom)
                    Capsule()
                        .fill(Color(.systemGray))
                        .frame(height: 40)
                        .overlay(Text("Introduce yourself").foregroundColor(.white))
                    HStack(){
                        Capsule()
                            .fill(Color(.systemGray))
                            .frame(width: .infinity, height: 40)
                            .overlay(Text("Ask for the gate").foregroundColor(.white))
                        Capsule()
                            .fill(Color(.systemGray))
                            .frame(width: .infinity, height: 40)
                            .overlay(Text("Ask for assistance").foregroundColor(.white))
                    }
                    .padding(.bottom)
                    HStack(){
                        Button(role:.destructive) {
                            
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.title)
                        }
                        .controlSize(.extraLarge)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        Spacer()
                        Button() {
                            
                        } label: {
                            Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                                .font(.title)
                        }
                        .controlSize(.extraLarge)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        Button() {
                            
                        } label: {
                            Image(systemName: "speaker.wave.2")
                                .font(.title)
                        }
                        .controlSize(.extraLarge)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                    }
                }
            }
        }
    }
}

#Preview {
    TextInputView()
}
