//
//  NSDraggingInfo+Utility.swift
//  Resizr
//
//  Created by Kyle Bendelow on 3/14/19.
//  Copyright © 2019 Onur Geneş. All rights reserved.
//

import Cocoa

extension NSDraggingInfo {
    /// Returns path of dragged item if available 
    var path: String? {
        guard let pasteboard = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray else {
            return nil
        }
        guard let path = pasteboard.firstObject as? String else {
            return nil
        }
        
        return path
    }
}
