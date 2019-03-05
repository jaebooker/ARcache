//
//  Cache.swift
//  ARcache
//
//  Created by Jaeson Booker on 3/4/19.
//  Copyright © 2019 Jaeson Booker. All rights reserved.
//

import Foundation

struct Cache: Encodable, Decodable {
    let _id: Int = 0
    var notes: [String]
    let xcoordinate: Double
    let ycoordinate: Double
}
