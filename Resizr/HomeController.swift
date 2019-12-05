//
//  HomeController.swift
//  Resizr
//
//  Created by Onur Geneş on 5.03.2019.
//  Copyright © 2019 Onur Geneş. All rights reserved.
//

import Cocoa

class HomeController: NSViewController {
    
    @IBOutlet private var dragView: DragView!
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    private var selectedFolder: URL?
    private var selectedAssetName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragView.delegate = self
        title = "Resizr"
        segmentedControl.selectedSegment = 0
    }
    
    @IBAction private func openSelection(_ sender: Any) {
        selectFolder()
    }
    
    private func selectFolder() {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.selectedFolder = panel.urls.first
                switch self.segmentedControl.selectedSegment {
                case 0:
                    self.save(image: self.imageView.image!, url: self.selectedFolder)
                case 1:
                    self.save(asset: self.imageView.image!, url: self.selectedFolder)
                default:
                    break
                }
                
            }
        }
    }

    private func infoAbout(url: URL) -> String {
        
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
    
    private func resize(image: NSImage, completion: @escaping ([String: NSImage]?, String?) -> ()) {
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
    
    private func assetResize(image: NSImage, completion: @escaping ([String: NSImage]?, String?) -> ()) {
        var images = [String: NSImage]()
        let rep = image.representations[0]
        let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        let sizes = ["asset@1x": NSSize(width: size.width / 3, height: size.height / 3),
                     "asset@2x": NSSize(width: (size.width / 3) * 2, height: (size.height / 3) * 2),
                     "asset@3x": size]
        
        for (key, value) in sizes {
            DispatchQueue.global(qos: .userInitiated).async {
                if let resizedImage = image.scaled(to: value) {
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
    
    private func save(asset: NSImage, url: URL?) {
        self.assetResize(image: asset) { (imagesDict, errorString) in
            if let error = errorString {
                print(error)
                return
            }
            
            guard let imagesDict = imagesDict else { return }
            guard let selectedFolder = url else { return }
            let withFolder = selectedFolder.appendingPathComponent("Resizr").appendingPathComponent("asset").appendingPathComponent("iOS")
            var withAssetSet = withFolder
            if let selectedAssetName = self.selectedAssetName {
                withAssetSet = withAssetSet.appendingPathComponent(selectedAssetName + ".imageset")
            } else {
                withAssetSet = withFolder.appendingPathComponent("asset.imageset")
            }
            do {
                try FileManager.default.createDirectory(at: withFolder, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.createDirectory(at: withAssetSet, withIntermediateDirectories: true, attributes: nil)
                for (name, image) in imagesDict {
                    let urlWithName = withAssetSet.appendingPathComponent(name + ".png")
                    guard let tiffRepresantation = image.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresantation) else { return }
                    let png = bitmapImage.representation(using: .png, properties: [:])
                    do {
                        try png?.write(to: urlWithName)
                    } catch let error {
                        print(error)
                    }
                }
                guard let filePath = Bundle.main.url(forResource: "AssetContents", withExtension: "json") else { return }
                let originalData = try Data(contentsOf: filePath)
                try originalData.write(to: withAssetSet.appendingPathComponent("Contents.json"))
            } catch let error {
                print(error)
            }
        }
    }
    
    private func save(image: NSImage, url: URL?) {
        resize(image: image) { (imagesDict, errorString) in
            if let error = errorString {
                print(error)
                return
            }
            
            guard let imagesDict = imagesDict else { return }
            guard let selectedFolder = url else { return }
            let withFolder = selectedFolder.appendingPathComponent("Resizr").appendingPathComponent("icon").appendingPathComponent("iOS")
            let withAppIconSet = withFolder.appendingPathComponent("AppIcon.appiconset")
            do {
                try FileManager.default.createDirectory(at: withFolder, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.createDirectory(at: withAppIconSet, withIntermediateDirectories: true, attributes: nil)
                for (name, image) in imagesDict {
                    let urlWithName = withAppIconSet.appendingPathComponent(name)
                    guard let tiffRepresentation = image.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return }
                    let png = bitmapImage.representation(using: .png, properties: [:])
                    do {
                        try png?.write(to: urlWithName)
                        if name.contains("tunes") {
                            try  png?.write(to: withFolder.appendingPathComponent(name))
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
        selectedAssetName = url.deletingPathExtension().lastPathComponent
    }
}
