//
//  VideoFilterManager.swift
//  VideoDreamer
//
//  Created by Yinjing Li on 3/2/23.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

let TOLERANCE_SCALE: CGFloat = 20.0

@objc class VideoFilterManager: NSObject {

    @objc static let shared = VideoFilterManager()
    
    @objc var mediaObjectView: MediaObjectView!
    
    @objc func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat, edges: CGFloat, opacity: CGFloat) -> CIFilter? {
        // 1
        let size = 64
        let count = size * size * size * 4
        let pointer = UnsafeMutablePointer<Float>.allocate(capacity: count)
        pointer.initialize(repeating: 0.0, count: count)
        defer {
            pointer.deinitialize(count: count)
            pointer.deallocate()
        }
            
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size - 1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size - 1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size - 1)
                        
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue + opacity / 10.0 && hue <= toHue + opacity / 10.0) ? 0.0 : 1.0
                    
                    // 4
                    pointer.advanced(by: (z * size * size + y * size + x) * 4).pointee = Float(red)
                    pointer.advanced(by: (z * size * size + y * size + x) * 4 + 1).pointee = Float(green)
                    pointer.advanced(by: (z * size * size + y * size + x) * 4 + 2).pointee = Float(blue)
                    pointer.advanced(by: (z * size * size + y * size + x) * 4 + 3).pointee = Float(alpha)
                }
            }
        }
        
        let buffer = UnsafeBufferPointer(start: pointer, count: count)
        let data = Data(buffer: buffer)

        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    /*@objc func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat, edges: CGFloat, opacity: CGFloat) -> CIFilter? {
        // 1
        let size = 64
        let count = size * size * size * 4
        let pointer = UnsafeMutablePointer<Float>.allocate(capacity: count)
        pointer.initialize(repeating: 0.0, count: count)
        defer {
            pointer.deinitialize(count: count)
            pointer.deallocate()
        }
            
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size - 1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size - 1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size - 1)
                        
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    var distance: CGFloat
                    if (fromHue <= hue) && (hue <= toHue) {
                        distance = min(abs(hue - fromHue), abs(hue - toHue)) / ((toHue - fromHue) / 2.0)
                    } else {
                        distance = 0.0
                    }
                    distance = 1.0 - distance
                    let alpha = sin(.pi * distance - .pi / 2.0) * 0.5 + 0.4 + opacity / 10.0
                    //print(alpha)
                    
                    // 4
                    pointer.advanced(by: (z * size * size + y * size + x) * 4).pointee = Float(red)
                    pointer.advanced(by: (z * size * size + y * size + x) * 4 + 1).pointee = Float(green)
                    pointer.advanced(by: (z * size * size + y * size + x) * 4 + 2).pointee = Float(blue)
                    pointer.advanced(by: (z * size * size + y * size + x) * 4 + 3).pointee = Float(alpha)
                }
            }
        }
        
        let buffer = UnsafeBufferPointer(start: pointer, count: count)
        let data = Data(buffer: buffer)

        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }*/
    
    @objc func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    @objc func getHue(color: UIColor) -> CGFloat {
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    @objc func chromakeyFilterImage(foregroundImage: CIImage, backgroundImage: CIImage) -> CIImage? {
        let chromaKeyFilter = chromaKeyFilter(fromHue: 0.3, toHue: 0.4, edges: 0.1, opacity: 1.0)
        chromaKeyFilter?.setValue(foregroundImage, forKey: kCIInputImageKey)
        let ciImage = chromaKeyFilter?.outputImage
        return ciImage
    }
    
    /*@objc func edgesFilterImage(image: CIImage, edges: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIUnsharpMask")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(2.5, forKey: kCIInputRadiusKey)
        filter?.setValue(edges, forKey: kCIInputIntensityKey)
        let ciImage = filter?.outputImage
        return ciImage
    }*/
    
    @objc func edgesFilterImage(image: CIImage, edges: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIEdgeWork")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(edges, forKey: kCIInputRadiusKey)
        let ciImage = filter?.outputImage
        return ciImage
    }
    
    @objc func noiseFilterImage(image: CIImage, noise: CGFloat, sharp: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CINoiseReduction")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(noise / 20.0, forKey: "inputNoiseLevel")
        filter?.setValue(sharp, forKey: kCIInputSharpnessKey)
        let ciImage = filter?.outputImage
        return ciImage
    }
    
    @objc func medianFilterImage(image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CIMedianFilter")
        filter?.setValue(image, forKey: kCIInputImageKey)
        let ciImage = filter?.outputImage
        return ciImage
    }
    
    @objc func lineOverlayFilterImage(image: CIImage) -> CIImage? {
        let filter = CIFilter(name: "CILineOverlay")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(0.08, forKey: "inputNRNoiseLevel")
        filter?.setValue(0.80, forKey: "inputNRSharpness")
        filter?.setValue(1.00, forKey: "inputEdgeIntensity")
        filter?.setValue(0.60, forKey: "inputThreshold")
        filter?.setValue(50.0, forKey: "inputContrast")
        let ciImage = filter?.outputImage
        return ciImage
    }
    
    @available(iOS 13.0, *)
    @objc func chromaKeyFilter(targetRed: Float, green targetGreen: Float, blue targetBlue: Float, threshold: Float, opacity: Float) -> CIFilter {
        let size = 64
        var data = Data(count: size * size * size * MemoryLayout<Float>.size * 4)
        data.withUnsafeMutableBytes { (cubeData: UnsafeMutableRawBufferPointer) -> Void in
            var c = cubeData.bindMemory(to: Float.self).baseAddress!
            // Populate cube with a simple gradient going from 0 to 1
            for z in 0 ... size - 1 {
                let blue = Float(z) / Float(size - 1) // Blue value
                for y in 0 ... size - 1 {
                    let green = Float(y) / Float(size - 1) // Green value
                    for x in 0 ... size - 1 {
                        let red = Float(x) / Float(size - 1) // Red value
                        // Convert RGB to HSV
                        // You can find publicly available rgbToHSV functions on the Internet
                        // rgbToHSV(rgb, hsv);
                        // Use the hue value to determine which to make transparent
                        // The minimum and maximum hue angle depends on
                        // the color you want to remove
                        // float alpha = (hsv[0] > minHueAngle && hsv[0] < maxHueAngle) ? 0.0f: 1.0f;
                        let distance = sqrt(pow((red - targetRed) * opacity, 2) + pow((green - targetGreen) * opacity, 2) + pow((blue - targetBlue) * opacity, 2))
                        let alpha: Float = distance < threshold ? 0.0 : 1.0;
                        // Calculate premultiplied alpha values for the cube
                        if alpha == 0 {
                            c.pointee = red * alpha
                            c = c.advanced(by: 1)
                            c.pointee = green * alpha
                            c = c.advanced(by: 1)
                            c.pointee = blue * alpha
                            c = c.advanced(by: 1)
                            c.pointee = alpha
                            c = c.advanced(by: 1)
                        } else {
                            //if distance >= 0.56 {
                                c.pointee = red * alpha
                                c = c.advanced(by: 1)
                                c.pointee = green * alpha
                                c = c.advanced(by: 1)
                                c.pointee = blue * alpha
                                c = c.advanced(by: 1)
                                c.pointee = alpha
                                c = c.advanced(by: 1)
                            /*} else {
                                let hue: CGFloat = getHue(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue))
                                let offset: CGFloat = 0.0166666666667
                                var targetHue = getHue(red: CGFloat(targetRed), green: CGFloat(targetGreen), blue: CGFloat(targetBlue))
                                targetHue += offset
                                var minHue = targetHue
                                var maxHue = targetHue
                                minHue -= CGFloat(threshold) / TOLERANCE_SCALE
                                maxHue += CGFloat(threshold) / TOLERANCE_SCALE

                                //print("minHue: \(minHue)")
                                //print("maxHue: \(maxHue)")
                                //print(hue)

                                let alpha: CGFloat = (hue >= minHue && hue <= maxHue) ? 0.0 : 1.0

                                c.pointee = red * Float(alpha)
                                c = c.advanced(by: 1)
                                c.pointee = green * Float(alpha)
                                c = c.advanced(by: 1)
                                c.pointee = blue * Float(alpha)
                                c = c.advanced(by: 1)
                                c.pointee = Float(alpha)
                                c = c.advanced(by: 1)
                            }*/
                        }
                    }
                }
            }
        }

        let colorCube = CIFilter.colorCube()
        colorCube.cubeDimension = Float(size)
        colorCube.cubeData = data
        return colorCube
    }
    
    @objc func opacityFilter(_ opacity: CGFloat) -> CIFilter {
        let opacityFilter = CIFilter(name: "CIColorMatrix")!
        opacityFilter.setDefaults()
        //opacityFilter.setValue(CIVector(x: 1, y: 0, z: 0, w: 1), forKey: "inputRVector")
        //opacityFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 1), forKey: "inputGVector")
        //opacityFilter.setValue(CIVector(x: 0, y: 0, z: 1, w: 1), forKey: "inputBVector")
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: opacity), forKey: "inputAVector")
        return opacityFilter
    }
    
    @objc func drawOutlie(image: UIImage, color: UIColor) -> UIImage? {
        let newImageKoef: CGFloat = 1.08
      
        let outlinedImageRect = CGRect(x: 0.0, y: 0.0, width: image.size.width * newImageKoef, height: image.size.height * newImageKoef)
      
        let imageRect = CGRect(x: image.size.width * (newImageKoef - 1) * 0.5, y: image.size.height * (newImageKoef - 1) * 0.5, width: image.size.width, height: image.size.height)
      
        UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, newImageKoef)
      
        image.draw(in: outlinedImageRect)
      
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.sourceIn)
      
        context?.setFillColor(color.cgColor)
        context?.fill(outlinedImageRect)
        image.draw(in: imageRect)
      
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
      
        return newImage
    }
}
