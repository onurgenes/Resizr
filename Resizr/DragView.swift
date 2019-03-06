//
//  DragView.swift
//  Resizr
//
//  Created by Onur Geneş on 5.03.2019.
//  Copyright © 2019 Onur Geneş. All rights reserved.
//

import Cocoa

class DragView: NSView {
    
    var delegate: DragViewDelegate?
    
    var filePath: String?
    private var acceptedFileExtensions = ["jpg", "png"]

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.layer?.backgroundColor = NSColor.blue.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String
        else { return false }
        
        let url = URL(fileURLWithPath: path)
        delegate?.dragView(didDragFileWith: url)
        return true
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.acceptedFileExtensions {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }
}
