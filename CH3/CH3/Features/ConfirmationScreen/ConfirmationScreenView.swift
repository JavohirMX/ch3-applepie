//
//  ConfirmationScreen.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 03/06/26.
//

import SwiftUI

struct ConfirmationScreenView: View {
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                VStack{
                    Text("Your flight information")
                        .font(.title)
                        .padding(.bottom, 20)
                    VStack(alignment: .leading, spacing:20){
                        VStack(alignment: .leading){
                            Text("Name")
                            Text("VoidMask").font(.title2)
                        }
                        VStack(alignment: .leading){
                            Text("From")
                            Text("Jakarta (CGK)").font(.title2)
                        }
                        VStack(alignment: .leading){
                            Text("To")
                            Text("Bali (DPS)").font(.title2)
                        }
                        HStack(){
                            VStack(alignment: .leading){
                                Text("Flight")
                                Text("QZ123").font(.title2)
                            }.frame(width: 100, alignment: .leading)
                            VStack(alignment: .leading){
                                Text("Date")
                                Text("10 JUN").font(.title2)
                            }.frame(width: 100, alignment: .leading)
                            VStack(alignment: .leading){
                                Text("Time")
                                Text("11:00").font(.title2)
                            }.frame(width: 100, alignment: .leading)
                        }
                        HStack(){
                            VStack(alignment: .leading){
                                Text("Seat")
                                Text("12E").font(.title2)
                            }.frame(width: 100, alignment: .leading)
                            VStack(alignment: .leading){
                                Text("Gate")
                                Text("3").font(.title2)
                            }.frame(width: 100, alignment: .leading)
                            VStack(alignment: .leading){
                                Text("Boarding")
                                Text("10:00").font(.title2)
                            }.frame(width: 100, alignment: .leading)
                        }
                    }
                }.padding(20).background(Color(.systemGray6))
                Spacer()
                VStack(spacing:12){
                    Capsule()
                        .fill(Color(.blue))
                        .frame(width: .infinity, height: 50)
                        .overlay(Text("Confirm").foregroundColor(.white).font(.title2))
                    Button("I want to edit this booking"){
                    }
                }.padding(20)
                .background(Color(.systemGray5)
                    .clipShape(
                        .rect(topLeadingRadius: 32,
                              topTrailingRadius: 32)
                    )
                    .ignoresSafeArea(edges: .bottom))
            }

        }
    }
}

#Preview {
    ConfirmationScreenView()
}
