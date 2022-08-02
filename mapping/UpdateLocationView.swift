//
//  UpdateLocationView.swift
//  mapping
//
//  Created by t&a on 2022/07/27.
//

import SwiftUI

struct UpdateLocationView: View {
    
    var fileController = FileController()
    @EnvironmentObject var allLocation : AllLocation
    
    @State var item:Location
    
    
    // --------------------------------------------
    @ObservedObject var locationManager = LocationManager()
    
    @State var selectedSpot:Spot = Spot.house
    @State var address:String = ""  // 住所
    @State var name:String = ""   // 名称
    @State var memo:String = ""  // メモ
    @State var hasInput:Bool = true
    
    var parentRefreshFunction:() -> Void
    
    // 登録ボタンを押下後初期化処理
    func clearInput (){
        address = ""
        name = ""
        memo = ""
    }
    
    func validationInput() -> Bool{
        if(address.isEmpty || name.isEmpty){
            hasInput = false
            return false
        }else{
            hasInput = true
            return true
        }
    }
    
    var body: some View {
        NavigationView{
            
            VStack(){
                HStack {
                    Spacer()
                    Button(action: {
                        
                        if (validationInput()){
                            // ジオコーディングメソッド呼び出し
                            locationManager.geocode(addressKey:address) { location in
                                guard let location = location else {
                                    // ジオコーディングできない住所を渡された可能性
                                    return
                                }
                                
                                let locate =  Location(address: address,
                                                       name: name,
                                                       memo: memo,
                                                       spot: selectedSpot,
                                                       latitude: location.latitude,
                                                       longitude: location.longitude)
                                
                                // 構造体をJSON形式としてファイルの保存
                                fileController.saveJson(locate)
                                
                                parentRefreshFunction()
                                
                            }
                            
                        }
                        
                    }, label: {
                        Image(systemName: "goforward.plus")
                            .foregroundColor(selectedSpot.spotColor)
                })
                }.padding([.top, .trailing]) // HStack
                Section{
                    Group{
                        TextField("住所", text: $address)
                        // 下線を表示
                        Rectangle()
                            .foregroundColor(selectedSpot.spotColor)
                            .frame(height: 2)
                        
                        if (!hasInput){
                            Text("住所が間違っている可能性があります。").font(.caption).foregroundColor(.red)
                        }else{
                            Text("存在する住所を入力してください").font(.caption).foregroundColor(.gray)
                        }
                    }
                    
                    
                    VStack {
                        TextField("名称", text: $name)
                        Rectangle()
                            .foregroundColor(selectedSpot.spotColor)
                            .frame(height: 2)
                    }.padding(.bottom)
                    
                    HStack {
                        Image(systemName: "text.justify.left")
                        Text("MEMO")
                        Spacer()
                    } .foregroundColor(selectedSpot.spotColor)
                    TextEditor(text: $memo).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                        .frame(height: 100)
                        .padding(.bottom)
                }.font(.system(size: 20)) // Section
                
                
                
                
                // Spotをピッカーで選択できるように表示----------
                
                
                NavigationLink {
                    SpotPickerView(selectedSpot: $selectedSpot)
                } label: {
                    // アクセントカラーで色変更されている
                    Image(systemName:selectedSpot.spotImage)
                    Text(selectedSpot.rawValue)
                    Spacer()
                    Image(systemName:"chevron.right").foregroundColor(.gray)
                    
                }
                
                // Spotをピッカーで選択できるように表示----------
                Spacer()
                
                
            }.navigationBarHidden(true)
        }.accentColor(selectedSpot.spotColor) // NavigationView
            .padding()
    }
}


struct UpdateLocationView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateLocationView(item: Location(address: "東京都千代田区千代田１−１", name: "東京スカイツリー", memo: "良い場所", spot: .facility, latitude: 35.709152712026265, longitude: 139.80771829999996),parentRefreshFunction: {}).previewLayout(.sizeThatFits)
    }
}
