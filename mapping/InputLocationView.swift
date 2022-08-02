//
//  InputLocationView.swift
//  mapping
//
//  Created by t&a on 2022/07/22.
//

import SwiftUI
import MapKit

// ContentView > HeaderView > InputLocationView
// ContentView > ListLocationView > RowLocationView > DetailLocationView > InputLocationView
// ContentView > MappingView
// ContentView > CurrentMapView

struct InputLocationView: View {
    
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    // MapModels：ジオコーディングメソッド呼び出し用
    @ObservedObject var locationManager = LocationManager()
    // JSONファイル操作クラス
    var fileController = FileController()
    
    // バインディングされる表示/非表示プロパティ
    @Binding var isModal:Bool // モーダル真偽値
    
    // 構造体プロパティInput
    @State var item:Location? = nil // DetailLocationViewからの遷移でLocationを受け取った場合の格納場所
    @State var id:UUID = UUID()     // id ← DetailLocationViewからの遷移時のみ格納
    @State var address:String = ""  // 住所
    @State var name:String = ""     // 名称
    @State var memo:String = ""     // メモ
    @State var selectedSpot:Spot = Spot.restaurant // Spot
    
    @State var isAlert:Bool = false     // 新規登録/更新処理を実行したアラート
    @State var hasInput:Bool = false    // 登録/更新ボタン押下時にInputに値があるかどうか
    @State var hasAddress:Bool = true   // 実在する住所だったかどうか
    @State var hasLocation:Bool = false // DetailLocationViewからの遷移でLocationを受け取ったかどうか
    
    // 親メソッドを受けとる
    var parentUpdateItemFunction: (_ data:Location) -> Void
    
    // 画面表示イベント時(onApper)に呼び出し初期化
    func setupInputValue (){
        if let location = self.item {
            // DetailLocationViewからの遷移の場合のみ実行される
            self.address = location.address
            self.name = location.name
            self.memo = location.memo
            if(self.hasLocation == false){
                // 初回のみ格納 Spot選択画面から戻った際にもリセットされてしまうため
                self.selectedSpot = location.spot
            }
            self.id = location.id
            self.hasLocation = true
        }
    }

    
    // 登録ボタンを押下後初期化処理
    func clearInput (){
        address = ""
        name = ""
        memo = ""
    }
    
    // バリデーション
    func validationInput() -> Bool{
        if(address.isEmpty || name.isEmpty){
            hasInput = true // 住所したメッセージ表示用
            return false
        }else{
            hasInput = false // 住所したメッセージ表示用
            return true
        }
    }
    
    var body: some View {
        NavigationView{
            VStack(){
                Section{  // 住所/名称/MEMO
                    // 住所-----------------------------
                    Group{
                        TextField("住所", text: $address).padding(.top)
                        // 下線を表示
                        Rectangle()
                            .foregroundColor(selectedSpot.spotColor)
                            .frame(height: 2)
                        
                        if (!hasInput){
                            if(hasAddress){
                                Text("実在する住所を入力してください" ).font(.caption).foregroundColor(.gray)
                            }else{
                                Text("存在しない住所です").font(.caption).foregroundColor(.red)
                            }
                        }else{
                            Text("住所と名称は必須項目です").font(.caption).foregroundColor(.red)
                        }
                    }
                    
                    // 名称-----------------------------
                    VStack {
                        TextField("名称", text: $name)
                        Rectangle()
                            .foregroundColor(selectedSpot.spotColor)
                            .frame(height: 2)
                    }.padding(.vertical)
                    
                    // MEMO-----------------------------
                    HStack {
                        Image(systemName: "text.justify.left")
                        Text("MEMO")
                        Spacer()
                    } .foregroundColor(selectedSpot.spotColor)
                    
                    TextEditor(text: $memo)
                        .padding() // Editorの中の余白
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                        .frame(height: 100)
                        .padding(.bottom) // Editorの外の余白
                    
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
                
                
            } // VStack
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(selectedSpot.spotColor) // NavigationView
            .navigationBarBackButtonHidden(true)
            .padding()
            .onAppear(perform: {
                // 画面が表示された時に実行されるイベント処理
                self.setupInputValue()
            })
            .toolbar(){
                
                // 戻るボタン--------------------------------------------
                ToolbarItem(placement: .navigationBarLeading, content: {
                    
                    Button(action:{
                        isModal = false
                    },label: {
                        Image(systemName:"arrow.backward")
                    }).foregroundColor(selectedSpot.spotColor)
                })
                // 戻るボタン--------------------------------------------
                
                // 登録ボタン--------------------------------------------
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    
                    Button(action: {
                        
                        
                        if (validationInput()){
                            // ジオコーディングメソッド呼び出し
                            locationManager.geocode(addressKey:address) { location in
                                guard let location = location else {
                                    hasAddress = false
                                    return // ジオコーディングできない住所を渡された可能性
                                }
                                let data =  Location(address: address,
                                                     name: name,
                                                     memo: memo,
                                                     spot: selectedSpot,
                                                     latitude: location.latitude,
                                                     longitude: location.longitude)
                                if(hasLocation){
                                    // 更新処理
                                    allLocation.updateLocation(data,id)            // 共有クラスを更新
                                    fileController.updateJson(allLocation.allData) // JSONファイル更新
                                    parentUpdateItemFunction(data) // Listで回ってきたitemへの格納処理
                                    isAlert = true  // 更新処理の際はモーダルを閉じるとDetailViewまで閉じられるのでアラートを表示
                                }else{
                                    // 新規追加
                                    fileController.saveJson(data)
                                    allLocation.setAllData() // 共有クラスを更新
                                    isModal = false // 新規登録の際はそのまま閉じる
                                }
                            }
                        }
                        
                    }, label: {
                        Image(systemName: "goforward.plus")
                            .foregroundColor(selectedSpot.spotColor)
                    })
                    .alert(isPresented: $isAlert){
                        Alert(title:Text("更新処理"),
                              message: Text("データを更新しました。"),
                              dismissButton: .default(Text("OK"),
                              action: {
                                isModal = false
                        }))
                    }
                }) // Toolbar
                // 登録ボタン--------------------------------------------
            }  // VStack
        } // NavigationView
        
    }
}

struct InputLocationView_Previews: PreviewProvider {
    static var previews: some View {
        InputLocationView(isModal: Binding.constant(true),parentUpdateItemFunction:{ data in })
    }
}
