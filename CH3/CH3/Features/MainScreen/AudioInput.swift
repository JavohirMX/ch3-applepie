//
//  AudioInput.swift
//  CH3
//
//  Created by Aulia Nadhirah Yasmin Badrulkamal on 04/06/26.
//

import SwiftUI

struct AudioInputView: View {
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                VStack{
                    ScrollView {
                        Text("Your flight QZ123 has been delayed due to severe weather conditions in Bali. Please check the monitors for further updates regarding your departure time. We apologize for the inconvenience and will provide meal vouchers at the gate.")
                            .padding()
                            .font(.title2)
                    }
                    .frame(width: 350, height: 550) // The box stays this exact size
//                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    Spacer()
                    Button() {
                        
                    } label: {
                        Image(systemName: "mic.fill")
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

#Preview {
    AudioInputView()
}
