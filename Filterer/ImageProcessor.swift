//
//  ImageProcessor.swift
//  Filterer
//
//  Created by Ivan on 12/9/15.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ImageProcessor: NSObject {
    private var image: RGBAImage
    
    //Here are the parameters of the filter. You can change any value - it will have a great impact on the image.
    //I made 5 "default" configurations (i.e., they correspond to differenet effects on the image)
    
    private var filters = [
        "Sharpen": [-1, -1, -1, -1, 9, -1, -1, -1, -1],
        "Washout": [-1, -1, -1, -1, 10, -1, -1, -1, -1],
        "Blur": [0.05, 0.1, 0.05, 0.1, 0.4, 0.1, 0.05, 0.1, 0.05],
        "Edges": [-1, -1, -1, -1, 8, -1, -1, -1, -1],
        "Embossing": [2, 0, 0, 0, -1, 0, 0, 0, -1] //need to greyscale beforehand!
    ]
    
    //this method applies the above mentioned "matrix" of the filter to the image
    
    func applyFilter(var filter: [Double]) -> UIImage? {
        let imageCopy = RGBAImage(image: image.toUIImage()!)!
        filter = normaliseMatrix(filter)
        for currentHeight in 0..<imageCopy.height {
            for currentWidth in 0..<imageCopy.width {
                let index = currentHeight * imageCopy.width + currentWidth
                if filterIsApplicable(index) {
                    var totalRed: Double = 0
                    var totalGreen: Double = 0
                    var totalBlue: Double = 0
                    
                    let neighbourPixels = computeNeighbourPixels(index)
                    var pixel = image.pixels[index]
                    
                    for coefficientIndex in 0..<filter.count {
                        totalRed += Double(image.pixels[neighbourPixels[coefficientIndex]].red) * filter[coefficientIndex]
                        totalGreen += Double(image.pixels[neighbourPixels[coefficientIndex]].green) * filter[coefficientIndex]
                        totalBlue += Double(image.pixels[neighbourPixels[coefficientIndex]].blue) * filter[coefficientIndex]
                        
                    }
                    
                    totalRed = max(min(totalRed, 255), 0)
                    totalGreen = max(min(totalGreen, 255), 0)
                    totalBlue = max(min(totalBlue, 255), 0)
                    
                    pixel.red = UInt8(totalRed)
                    pixel.green = UInt8(totalGreen)
                    pixel.blue = UInt8(totalBlue)
                    
                    imageCopy.pixels[index] = pixel
                }//if
            }//second for-loop
        }//first for-loop
        return imageCopy.toUIImage()
    }
    
    //this method is a simple "greyscale" filter. I've made it to make the "embossing" filter better
    
    func greyScale() -> UIImage? {
        let imageCopy = RGBAImage(image: image.toUIImage()!)!
        let greyScaleMatrix = [0.3, 0.59, 0.11]
        for currentHeight in 0..<imageCopy.height {
            for currentWidth in 0..<imageCopy.width {
                let index = currentHeight * imageCopy.width + currentWidth
                var pixel = imageCopy.pixels[index]
                let greyColor = Double(pixel.red) * greyScaleMatrix[0] + Double(pixel.green) * greyScaleMatrix[1] + Double(pixel.blue) * greyScaleMatrix[2]
                pixel.red = UInt8(greyColor)
                pixel.green = UInt8(greyColor)
                pixel.blue = UInt8(greyColor)
                imageCopy.pixels[index] = pixel
            }
        }
        return imageCopy.toUIImage()
    }
    
    func saturation(var intensity: Int) -> UIImage? {
        intensity = min(max(intensity, 0), 100)
        let imageCopy = RGBAImage(image: image.toUIImage()!)!
        for currentHeight in 0..<imageCopy.height {
            for currentWidth in 0..<imageCopy.width {
                let index = currentHeight * imageCopy.width + currentWidth
                var pixel = imageCopy.pixels[index]
                let colors = [pixel.red, pixel.green, pixel.blue]
                var newColors = [Double]()
                let highestColor = colors.maxElement()!
                var coefficient: Double
                if intensity == 0 {
                    coefficient = Double(intensity)
                }//if
                else {
                    coefficient = Double(intensity) / 100
                }//else
                for colorValue in colors {
                    var newColorValue = Double(colorValue)
                    if colorValue < highestColor {
                        newColorValue += (Double(highestColor) - Double(colorValue)) * coefficient
                        newColorValue = min(max(newColorValue, 0), 255)
                        newColors.append(newColorValue)
                    }//if
                    else {
                        newColorValue = min(max(newColorValue, 0), 255)
                        newColors.append(newColorValue)
                    }//else
                }//for
                
                pixel.red = UInt8(newColors[0])
                pixel.green = UInt8(newColors[1])
                pixel.blue = UInt8(newColors[2])
                imageCopy.pixels[index] = pixel
            }
        }
        return imageCopy.toUIImage()
    }
    
    //this method finds filters by their names and applies them
    
    func findAndApplyFilter(filter: String) -> UIImage? {
        if filter == "Grey" {
            return greyScale()
        }//if
        else if filter == "Saturation" {
            return saturation(50)
        }
        else {
            for (filterName, filterMatrix) in filters {
                if filter == filterName {
                    return applyFilter(filterMatrix)
                }//if
            }//for
        }//else
        return nil
    }
   
    private func filterIsApplicable(index: Int) -> Bool {
        if index >= image.width //should not be the first row
            && index <= image.width * (image.height - 1)//should not be the last row
            && index % image.width != 0 // should not be the first column
            && (index + 1) % image.width != 0 // chould not be the last column
        {
            return true
        }//if
        else {
            return false
        }//else
    }
    
    private func computeNeighbourPixels(index: Int) -> [Int] {
        return [index - image.width - 1, index - image.width, index - image.width + 1,
            index - 1, index, index + 1,
            index + image.width - 1, index + image.width, index + image.width + 1
        ]
    }
    
    private func normaliseMatrix(var matrix: [Double]) -> [Double] {
        if matrix.count == 9 {
            return matrix
        }//if
        else {
            if matrix.count < 9 {
                while matrix.count < 9 {
                    matrix.append(0)
                }//while
            }//if
            if matrix.count > 9 {
                while matrix.count > 9 {
                    matrix.removeLast()
                }
            }
            return matrix
        }//else
        
    }
    
    init(image: RGBAImage) {
        self.image = image
    }
}
