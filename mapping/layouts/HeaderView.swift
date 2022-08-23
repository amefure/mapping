//
//  HeaderView.swift
//  mapping
//
//  Created by t&a on 2022/07/26.
//

import SwiftUI

struct HeaderView: View {
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    
    // JSONファイル操作クラス
    var fileController = FileController()
    
    @State var isModal:Bool = false      // InputLocationView表示/非表示
    @State var isModalSpot:Bool = false  // InputLocationView表示/非表示
    @State var isLimitAlert:Bool = false // 上限に達した場合のアラート
    
    @Binding var selectedSpot:Spot?   // 選択されたSpot
    @Binding var selectedTag:Int      // 現在選択されているタグを共有
    @Binding var filter:Bool          // フィルターのON/OFF
    @Binding var isClickFilter:Bool         // ヘッダー左端ボタンを押されたかどうか：Filter
    @Binding var isClickUpdate:Bool         // ヘッダー左端ボタンを押されたかどうか：Map

    
    func limitCountData() -> Bool{
        if allLocation.countAllData() < fileController.loadLimitTxt() {
            // 現在の要素数 < 上限数
            return true
        }else{
            // 上限に達した場合
            isLimitAlert = true
            // 現在の要素数 = 上限数
            return false
        }
    }
    
    var body: some View {
        HStack{
            // 左端の全データ削除ボタン-----------------------------
            Group{
                    if(selectedTag == 1){ // フィルタリングボタン
                        Button(action: {
                            if(filter == false){
                                isClickFilter.toggle()
                            }else{
                                selectedSpot = nil
                            }
                            filter.toggle()
                        }, label: {
                            Image(systemName:"line.3.horizontal.decrease.circle")
                                .padding(.top,8)
                                .font(.system(size:25))
                        }).foregroundColor(filter ? .orange : .white)
                        
                    }else{  // 更新ボタン
                       
                        Button(action: {
                            isClickUpdate.toggle()
                        }, label: {
                            Image(systemName: "gobackward")
                                .padding(.top,8)
                                .font(.system(size:22))
                        })
                        
                    }
            }.frame(width: 25, height: 25).foregroundColor(.white)
            // 左端の全データ削除ボタン-----------------------------
            
            Spacer()
            
            Image("icon").resizable().aspectRatio(contentMode: .fill).frame(width: 30, height:  30)
            
            Spacer()
            
            // 右端の新規登録ボタン-----------------------------
            Button(action: {
                
                if limitCountData(){
                    isModal = true
                }else{
                    isLimitAlert = true
                }
                
            }, label: {
                VStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size:25))
                        .padding(.top,8)
                }.foregroundColor(Color("ThemaColor"))
            })
            // 右端の新規登録ボタン-----------------------------
            
        }.padding(.vertical,10)
            .padding(.horizontal,20)
            .background(Color( red: 0.4, green: 0.4, blue: 0.4))
            .sheet(isPresented: $isModal, content: {
                // parentUpdateItemFunctionには空のメソッドを渡す
                InputLocationView(isModal: $isModal,parentUpdateItemFunction: { data in }).environmentObject(allLocation)
            })
            .alert(isPresented: $isLimitAlert){
                Alert(title:Text("上限に達しました"),
                      message: Text("広告を見てSpotの枠を増やしてください。"),
                      dismissButton: .default(Text("OK")))
            }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(selectedSpot: Binding.constant(.house), selectedTag: Binding.constant(1),filter:Binding.constant(false),isClickFilter: Binding.constant(false),isClickUpdate: Binding.constant(false))
    }
}
