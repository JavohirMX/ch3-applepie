//
//  EmptyJourneyView.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 03/06/26.
//

import SwiftUI

struct EmptyJourneyView: View {
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Image("Placeholder")
                    .resizable()
                    .frame(width: 250, height: 250)
                Text("No ongoing journey")
                    .font(.largeTitle)
                Text("Setup your new journey, by providing us your boarding pass!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                HStack(){
                    Button {
                        
                    } label: {
                        Image(systemName: "photo.badge.plus.fill")
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    Button {
                        
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    Button {
                        
                    } label: {
                        Image(systemName: "folder.fill.badge.plus")
                            .font(.system(size: 24))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                }
                .padding(.top)
                Spacer()
            }.padding(.horizontal, 20)
                .padding(.bottom, 100)

        }
    }
}

#Preview {
    EmptyJourneyView()
}

