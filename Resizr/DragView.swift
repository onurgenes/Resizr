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
    
    private var filePath: String?
    private var acceptedFileExtensions = ["jpg", "png", "jpeg"]
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.wantsLayer = true
        layer?.appearActive(false)
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            layer?.appearActive(true)
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        layer?.appearActive(false)
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        layer?.appearActive(false)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let path = sender.path else {
            return false
        }
        
        let url = URL(fileURLWithPath: path)
        delegate?.dragView(didDragFileWith: url)
        return true
    }
    
    private func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let path = drag.path else {
            return false
        }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.acceptedFileExtensions {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }
}
