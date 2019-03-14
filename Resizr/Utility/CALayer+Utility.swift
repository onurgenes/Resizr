//
//  NSColor+Utility.swift
//  Resizr
//
//  Created by Kyle Bendelow on 3/14/19.
//  Copyright © 2019 Onur Geneş. All rights reserved.
//

import Cocoa

internal extension CALayer {
    /// Will make the parent view appear active or inactive (e.g. "active" setting will make the view turn blue)
    func appearActive(_ active: Bool) {
        // TODO: Make this look nice, apply fades, etc
        let color = active ? NSColor.blue : NSColor.gray
        backgroundColor = color.cgColor
    }
}
