//
//  LocationListView.swift
//  mapping
//
//  Created by t&a on 2022/07/23.
//

import SwiftUI

struct LocationListView: View {
    
//    @ObservedObject var allLocation = allLocation()
    
    var body: some View {
        
        
        VStack {
            List(allLocation().allData.reversed()) { item in
                Text(item.address)
            }
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}
