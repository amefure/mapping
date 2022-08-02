//
//  SpotPickerView.swift
//  mapping
//
//  Created by t&a on 2022/07/25.
//

import SwiftUI

struct SpotPickerView: View {
    // NavigationViewを閉じるメソッド
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedSpot:Spot
    
    var body: some View {
        
        VStack {
            ForEach(Spot.allCases, id: \.self) { spot in
                Button(action: {
                    selectedSpot = spot
                    dismiss()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3).fill(spot.spotColor)
                        HStack{
                            Text(spot.rawValue)
                            Image(systemName: spot.spotImage)
                        }.fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(spot.accentColor)
                    }.padding(5)
                })
            }
        }.navigationBarBackButtonHidden(true)
            .toolbar(){
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action:{
                        dismiss()
                    },label: {
                        Image(systemName:"arrow.backward")
                    }).foregroundColor(selectedSpot.spotColor)
                })
                
            }
    }
}
struct SpotPickerView_Previews: PreviewProvider {
    static var previews: some View {
        SpotPickerView(selectedSpot: Binding.constant(.others))
    }
}
