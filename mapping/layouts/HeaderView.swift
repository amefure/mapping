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
    
    @State var isModal:Bool = false    // InputLocationView表示/非表示
    @State var isAlert:Bool = false    // 全データ削除ボタンの確認アラート
    
    
    var body: some View {
        HStack{
            // 左端_の全データ削除ボタン-----------------------------
            Button(action: {
                isAlert = true
                
            }, label: {
                VStack {
                    Image(systemName: "trash.fill")
                        .padding(.top,8)
                    Text("削除")
                        .padding(1)
                        .font(.caption)
                }.foregroundColor(.white)
                
            })
            .alert(isPresented: $isAlert){
                Alert(title:Text("確認"),
                      message: Text("全てのデータを削除してもよろしいですか？"),
                      primaryButton: .destructive(Text("削除する"),
                      action: {
                        fileController.clearFile()
                        allLocation.setAllData()
                }), secondaryButton: .cancel(Text("キャンセル")))
            }
            // 左端の全データ削除ボタン-----------------------------
            
            Spacer()
            
            Image("icon").resizable().aspectRatio(contentMode: .fill).frame(width: 30, height:  30)
            
            Spacer()
            

            
            // 右端の新規登録ボタン-----------------------------
            Button(action: {
                isModal = true
            }, label: {
                VStack {
                    Image(systemName: "signpost.right.fill")
                        .padding(.top,8)
                    Text("登録")
                        .padding(1)
                        .font(.caption)
                    
                }.foregroundColor(.white)
            })
            // 右端の新規登録ボタン-----------------------------
            
        }.padding(.vertical,10)
            .padding(.horizontal,20)
            .background(Color( red: 0.4, green: 0.4, blue: 0.4))
            .sheet(isPresented: $isModal, content: {
                // parentUpdateItemFunctionには空のメソッドを渡す
                InputLocationView(isModal: $isModal,parentUpdateItemFunction: { data in }).environmentObject(allLocation)
            })
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
