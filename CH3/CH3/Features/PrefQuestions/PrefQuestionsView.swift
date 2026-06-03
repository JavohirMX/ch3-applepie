//
//  OnboardingView.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 03/06/26.
//
import SwiftUI

struct PrefQuestionsView: View {
    var body: some View {
        ZStack{
            VStack{
                HStack(){
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                    }
                    Spacer()
                    Button("Skip"){
                        
                    }
                }
                .padding(.bottom, 54)
                Text("Do you have any dietary restrictions or food allergies?")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                HStack{
                    VStack{
                        Image("Placeholder")
                            .resizable()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                        Text("None").font(.title2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                    VStack{
                        Image("Placeholder")
                            .resizable()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                        Text("None").font(.title2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                }
                HStack{
                    VStack{
                        Image("Placeholder")
                            .resizable()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                        Text("None").font(.title2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                    VStack{
                        Image("Placeholder")
                            .resizable()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                        Text("None").font(.title2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                }
                Spacer()
                
            }.padding(20)
        }
    }
}

#Preview {
    PrefQuestionsView()
}
