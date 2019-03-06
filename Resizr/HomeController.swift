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
    
    @IBAction func openSelection(_ sender: Any) {
        save(image: imageView.image!)
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
    
    func resize(image: NSImage, completion: @escaping ([String: NSImage]?, String?) -> ()) {
        var images = [String: NSImage]()
        let sizes = ["Icon-App-20x20@1x.png": 20,
                     "Icon-App-20x20@2x.png": 40,
                     "Icon-App-20x20@3x.png": 60,
                     "Icon-App-29x29@1x.png": 29,
                     "Icon-App-29x29@2x.png": 58,
                     "Icon-App-29x29@3x.png": 87,
                     "Icon-App-40x40@1x.png": 40,
                     "Icon-App-40x40@2x.png": 80,
                     "Icon-App-40x40@3x.png": 120,
                     "Icon-App-60x60@2x.png": 120,
                     "Icon-App-60x60@3x.png": 180,
                     "Icon-App-76x76@1x.png": 76,
                     "Icon-App-76x76@2x.png": 152,
                     "Icon-App-83.5x83.5@2x.png": 167,
                     "ItunesArtwork@1x.png": 512,
                     "ItunesArtwork@2x.png": 1024,
                     "ItunesArtwork@3x.png": 1536]
        
        for (key, value) in sizes {
            DispatchQueue.global(qos: .userInitiated).async {
                if let resizedImage = image.resized(to: value) {
                    let imageName = key
                    images[imageName] = resizedImage
                } else {
                    completion(nil, "Couldn't get image")
                    return
                }
                DispatchQueue.main.async {
                    completion(images, nil)
                }
            }
            
        }
    }
    
    func save(image: NSImage) {
        resize(image: image) { (imagesDict, errorString) in
            if let error = errorString {
                print(error)
                return
            }
            
            guard let imagesDict = imagesDict else { return }
            guard let downloadsFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
            let withFolder = downloadsFolder.appendingPathComponent("Resizr").appendingPathComponent("icon").appendingPathComponent("iOS")
            let withAppIconSet = withFolder.appendingPathComponent("AppIcon.appiconset")
            do {
                try FileManager.default.createDirectory(at: withFolder, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.createDirectory(at: withAppIconSet, withIntermediateDirectories: true, attributes: nil)
                for (name, image) in imagesDict {
                    let urlWithName = withAppIconSet.appendingPathComponent(name + ".png")
                    guard let tiffRepresentation = image.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return }
                    let png = bitmapImage.representation(using: .png, properties: [:])
                    do {
                        try png?.write(to: urlWithName)
                        if name.contains("tunes") {
                            try  png?.write(to: withFolder.appendingPathComponent(name + ".png"))
                        }
                    } catch let error {
                        print(error)
                    }
                }
                guard let filePath = Bundle.main.url(forResource: "Contents", withExtension: "json") else { return }
                let originalData = try Data(contentsOf: filePath)
                try originalData.write(to: withAppIconSet.appendingPathComponent("Contents.json"))
            } catch let error {
                print(error)
            }
        }
    }
}

extension HomeController: DragViewDelegate {
    func dragView(didDragFileWith url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        imageView.image = image
    }
}
