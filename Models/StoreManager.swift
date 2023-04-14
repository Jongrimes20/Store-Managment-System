//
//  StoreManager.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/16/22.
//
//  Defines the StoreManager struct
//  serves as our user

import Foundation

class StoreManager {
    var Name: String
    var storeNum: Int
    
    //initializer
    init(name: String, storeNum: Int) {
        self.Name = name
        self.storeNum = storeNum
    }
}
