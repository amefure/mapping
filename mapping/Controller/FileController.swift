//
//  FileController.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//

import Foundation

// [Location]を蓄積するためのFileController
class FileController {
    
    // Documents内でロケーションデータをJSON形式で格納
    private let jsonName:String = "location.json"
    // Documents内で追加できるロケーション数を格納
    private let txtName:String = "limitNum.txt"
    // デフォルト制限数
    private let defaultLimit:String = "10"
    
    // 念の為数値かチェック
    private func numCheck (_ str:String) -> Bool{
        guard Int(str) != nil else {
            return false // 文字列の場合
        }
        return true // 数値の場合
    }
    
    // 保存ファイルへのURLを作成 file::Documents/fileName
    private func docURL(_ fileName:String) -> URL? {
        let fileManager = FileManager.default
        do {
            // Docmentsフォルダ
            let docsUrl = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            // URLを構築
            let url = docsUrl.appendingPathComponent(fileName)
            
            return url
        } catch {
            return nil
        }
    }
    // 操作するJsonファイルがあるかどうか
    private func hasFile (_ fileName:String) -> Bool{
        
        let str =  NSHomeDirectory() + "/Documents/" + fileName
        if FileManager.default.fileExists(atPath: str) {
            return true
        }else{
            return false
        }
    }
    
    
    // ファイル削除処理
    func clearFile() {
        guard let url = docURL(jsonName) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
        }
    }
    
    // 登録する一件のキャッシュデータを受け取る
    // 現在のキャッシュALL情報を取得し構造体に変換してから追加
    // 再度JSONに直し書き込み
    func saveJson(_ location:Location) {
        guard let url = docURL(jsonName) else {
            return
        }
        
        var locationArray:[Location]
        
        locationArray = loadJson() // [] or [Location]
        locationArray.append(contentsOf: [location]) // いずれにせよ追加処理
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(locationArray)
        let jsonData = String(data:data, encoding: .utf8)!
        
        do {
            // ファイルパスへの保存
            let path = url.path
            try jsonData.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    // ListlocateViewからremoveされたデータを保存する
    func updateJson(_ allLocation:[Location]) {
        guard let url = docURL(jsonName) else {
            return
        }
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(allLocation)
        let jsonData = String(data:data, encoding: .utf8)!
        do {
            // ファイルパスへの保存
            let path = url.path
            try jsonData.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            print(error)
        }
    }
    
    // JSONデータを読み込んで[構造体]にする
    func loadJson() -> [Location] {
        
        guard let url = docURL(jsonName) else {
            return []
        }
        
        if hasFile(jsonName) {
            // JSONファイルが存在する場合
            let jsonData = try! String(contentsOf: url).data(using: .utf8)!
            let locationArray = try! JSONDecoder().decode([Location].self, from: jsonData)
            return locationArray
        }else{
            // JSONファイルが存在しない場合
            return []
        }
    }
    
    
    // LimitNum.txt---------------------------------------
    func loadLimitTxt() -> Int {
        
        
        guard let url = docURL(txtName) else {
            return Int(defaultLimit)!
        }
        
        
        do {
            if hasFile(txtName) {
                let currentLimit = try String(contentsOf: url, encoding: .utf8)
                
                if numCheck(currentLimit) {
                    return Int(currentLimit)!
                }else{
                    return Int(defaultLimit)!
                }
                
            }else{
                try defaultLimit.write(to: url,atomically: true,encoding: .utf8)
                return Int(defaultLimit)!
            }
            
        } catch{
            // JSONファイルが存在しない場合
            return Int(defaultLimit)!
        }
        
    }
    
    func addLimitTxt(){
        guard let url = docURL(txtName) else {
            return
        }
        do {
                var currentLimit = try String(contentsOf: url, encoding: .utf8)
                
                if numCheck(currentLimit) {
                    currentLimit = String(Int(currentLimit)! + 5)
                    try currentLimit.write(to: url,atomically: true,encoding: .utf8)
                }
            
        } catch{
            return
        }
        
    }
    
    
    
}

