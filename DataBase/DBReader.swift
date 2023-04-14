//
//  DBReader.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/19/22.
//
//  Performs all DB operations



import Foundation
import SQLite

func copyDatabaseIfNeeded(sourcePath: String) -> Bool {
    let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let destinationPath = documents + "/db.sqlite3"
    let exists = FileManager.default.fileExists(atPath: destinationPath)
    guard !exists else { return false }
    do {
        try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
        return true
    } catch {
      print("error during file copy: \(error)")
        return false
    }
}


func makeDBConnection() -> Connection {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let sourcePath = "\(path)/db.sqlite3"
    
    _ = copyDatabaseIfNeeded(sourcePath: sourcePath)
    
    return try! Connection(sourcePath)
}
