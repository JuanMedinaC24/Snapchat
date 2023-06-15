//
//  Snap.swift
//  MedinaSnapchat
//
//  Created by Mac 08 on 14/06/23.
//

import Foundation

class Snap {
    var imagenURL: String?
    var audioURL: String?
    var descripcion: String?
    var from: String?
    var id: String?
    var imagenID: String?
    var audioID: String?
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["imagenURL"] = imagenURL
        dictionary["audioURL"] = audioURL
        dictionary["descripcion"] = descripcion
        dictionary["from"] = from
        dictionary["id"] = id
        dictionary["imagenID"] = imagenID
        dictionary["audioID"] = audioID
        return dictionary
    }
}
