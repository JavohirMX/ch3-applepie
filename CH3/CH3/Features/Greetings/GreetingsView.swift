//
//  OnboardingView.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 03/06/26.
//
import SwiftUI

struct GreetingsView: View {
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Image("Placeholder")
                    .resizable()
                    .frame(width: 350, height: 350)
                Text("Empower Yourself")
                    .font(.largeTitle)
                Text("Don't let communication barrier ruined your solo travel plans.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                Spacer()
                Capsule()
                    .fill(Color(.blue))
                    .frame(width: .infinity, height: 60)
                    .overlay(Text("Next").foregroundColor(.white).font(.title))
            }.padding(.horizontal, 20)
            .padding(.vertical, 60)
        }
    }
}

#Preview {
    GreetingsView()
}
