//
//  FileManager+Utils.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/27/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import Foundation

extension FileManager {
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
