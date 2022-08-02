//
//  FileController.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//

import Foundation

// [Location]を蓄積するためのFileController
class FileController {
        
    // Documents内で操作するJSONファイル名
    private let jsonName:String = "location.json"
    
    // 保存ファイルへのURLを作成 file::Documents/fileName
    func docURL() -> URL? {
        let fileManager = FileManager.default
        do {
            // Docmentsフォルダ
            let docsUrl = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            // URLを構築
            let url = docsUrl.appendingPathComponent(jsonName)
            
            return url
        } catch {
            return nil
        }
    }


    // ファイル削除処理
    func clearFile() {
        guard let url = docURL() else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
        }
    }
    
    
    // 操作するJsonファイルがあるかどうか
    func hasJson () -> Bool{
        
        let str =  NSHomeDirectory() + "/Documents/" + jsonName
        if FileManager.default.fileExists(atPath: str) {
            return true
        }else{
            return false
        }
    }
    
    // 登録する一件のキャッシュデータを受け取る
    // 現在のキャッシュALL情報を取得し構造体に変換してから追加
    // 再度JSONに直し書き込み
    func saveJson(_ location:Location) {
        guard let url = docURL() else {
            
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
            print(jsonData)
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    // ListlocateViewからremoveされたデータを保存する
    func updateJson(_ allLocation:[Location]) {
        guard let url = docURL() else {
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
        
        guard let url = docURL() else {
            return []
        }
        
        if hasJson() {
            // JSONファイルが存在する場合
            let jsonData = try! String(contentsOf: url).data(using: .utf8)!
            let locationArray = try! JSONDecoder().decode([Location].self, from: jsonData)
            return locationArray
            
        }else{
            // JSONファイルが存在しない場合
            return []
            
        }
        


    }
    
}

