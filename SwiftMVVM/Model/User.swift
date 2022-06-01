//
//  User.swift
//  SwiftMVVM
//
//  Created by jaydeep vadalia on 01/06/22.
//

import Foundation

struct User: Decodable, Equatable {
    //var id: String
    var avatar_url: String
    var login: String
    var type: String
}
