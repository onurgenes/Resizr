//
//  HomeController.swift
//  Resizr
//
//  Created by Onur Geneş on 5.03.2019.
//  Copyright © 2019 Onur Geneş. All rights reserved.
//

import Cocoa

class HomeController: NSViewController {
    
    @IBOutlet var dragView: DragView!
    @IBOutlet weak var imageView: NSImageView!
    
    var selectedFolder: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragView.delegate = self
        title = "Resizr"
    }
    
    func selectFolder() {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.selectedFolder = panel.urls[0]
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func infoAbout(url: URL) -> String {
        
        let fileManager = FileManager.default
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            var report: [String] = ["\(url.path)", ""]
            
            for (key, value) in attributes {
                // ignore NSFileExtendedAttributes as it is a messy dictionary
                if key.rawValue == "NSFileExtendedAttributes" { continue }
                report.append("\(key.rawValue):\t \(value)")
            }
            return report.joined(separator: "\n")
        } catch {
            return "No information available for \(url.path)"
        }
    }
    
    func resize(image: NSImage) -> [String: NSImage] {
        var images = [String: NSImage]()
        let sizes = ["Icon-App-20x20@2x.png": 40,
                     "Icon-App-20x20@3x.png": 60,
                     "Icon-App-29x29@1x.png": 29,
                     "Icon-App-29x29@2x.png": 58,
                     "Icon-App-29x29@3x.png": 87,
                     "Icon-App-40x40@2x.png": 80,
                     "Icon-App-40x40@3x.png": 120,
                     "Icon-App-60x60@2x.png": 120,
                     "Icon-App-60x60@3x.png": 180,
                     "Icon-App-76x76@2x.png": 152,
                     "Icon-App-20x20@1x.png": 20,
                     "Icon-App-20x20@2x.png": 40,
                     "Icon-App-29x29@1x.png": 29,
                     "Icon-App-29x29@2x.png": 58,
                     "Icon-App-40x40@1x.png": 40,
                     "Icon-App-40x40@2x.png": 80,
                     "Icon-App-76x76@1x.png": 76,
                     "Icon-App-76x76@2x.png": 152,
                     "Icon-App-83.5x83.5@2x.png": 167,
                     "ItunesArtwork@1x.png": 512,
                     "ItunesArtwork@2x.png": 1024,
                     "ItunesArtwork@3x.png": 1536]
        
        for (key, value) in sizes {
            let resizedImage = image.resized(to: value)
            let imageName = key
            // TODO: save the file at Downloads folder within folders 
        }
        
//        let start = DispatchTime.now()
//
//        var images = [NSImage]()
//        sizes.forEach { (size) in
//            guard let image = image.resized(to: size) else { return }
//            images.append(image)
//        }
//        let end = DispatchTime.now()
//
//        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
//        let timeInterval = Double(nanoTime) / 1_000_000_000
//
//        print("Time to evaluate problem: \(timeInterval) seconds")
        return images
    }
}

extension HomeController: DragViewDelegate {
    func dragView(didDragFileWith url: URL) {
        let image = NSImage(contentsOf: url)
        imageView.image = image
        
        resize(image: image!)
        
        
//        let imageReps = NSBitmapImageRep.imageReps(withContentsOf: url)
//        let size = imageReps?.reduce(CGSize.zero, { (size: CGSize, rep: NSImageRep) -> CGSize in
//            return CGSize(width: max(size.width, CGFloat(rep.pixelsWide)), height: max(size.height, CGFloat(rep.pixelsHigh)))
//        })
        
//        var selectedImage = NSImage(byReferencing: url)
//        print(selectedImage.size.width)
//        print(selectedImage.size.height)
    }
}


extension NSImage {
    func resized(to newSize: Int) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: newSize, pixelsHigh: newSize,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
            ) {
            bitmapRep.size = NSSize(width: newSize, height: newSize)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize, height: newSize), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            
            let resizedImage = NSImage(size: NSSize(width: newSize, height: newSize))
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        
        return nil
    }
}
