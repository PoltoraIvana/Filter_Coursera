//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var filteredImage: UIImage?
    var originalImage: UIImage?
    
    @IBOutlet weak var originalLabelView: UIView!
    
    var filterWasApplied: Bool = false
    var showsOriginal: Bool = true
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondaryImageView: UIImageView!
        
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var secondaryMenuStack: UIStackView!
    @IBOutlet var filterSlider: UISlider!
    @IBOutlet var filterCollection: UICollectionView!
    @IBOutlet var screenCompareButton: UIButton!
    
    let availableFilters = ["Saturation", "Grey", "Sharpen", "Washout", "Blur", "Edges", "Embossing"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.65)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryImageView.alpha = 0.0
        originalLabelView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        filterCollection.dataSource = self
        filterCollection.delegate = self
        filterCollection.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.65)
    }

    // MARK: Share
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    
    @IBAction func onNewPhoto(sender: AnyObject) {
        hideEditSlider()
        hideFilterCollection()
        editButton.enabled = false
        editButton.selected = false
        screenCompareButton.enabled = false
        compareButton.enabled = false
        compareButton.selected = false
        if showsOriginal {
            compareImages(compareButton)
        }
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideFilterCollection()
            sender.selected = false
            
        } else {
            showFilterCollection()
            sender.selected = true
            screenCompareButton.enabled = false
        }
    }
    
//----------------------------------------------Edit slider for Saturation Filter----------------------------------------------
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected) {
            hideEditSlider()
            sender.selected = false
        }//if
        else {
            if filterCollection.hidden == false {
                hideFilterCollection()
            }//if
            showEditSlider()
            sender.selected = true
        }//else
    }
    
    func showEditSlider() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func hideEditSlider() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        imageView.image = secondaryImageView.image!
        let imageProcessor = ImageProcessor(image: RGBAImage(image: imageView.image!)!)
        if let newImage = imageProcessor.saturation(Int(sender.value)) {
            imageView.image = newImage
            filteredImage = newImage
            filterWasApplied = true
        }
    }
    
//----------------------------------------------Filter methods----------------------------------------------
    
    @IBAction func applyFilter(sender: UIButton) {
        secondaryImageView.image = imageView.image
        let imageProcessor = ImageProcessor(image: RGBAImage(image: imageView.image!)!)
        if let newImage = imageProcessor.findAndApplyFilter(sender.titleLabel!.text!) {
            secondaryImageView.alpha = 1
            imageView.alpha = 0
            imageView.image = newImage
            self.imageView.alpha = 1
            UIView.animateWithDuration(0.4) {
                self.secondaryImageView.alpha = 0
            }
            filteredImage = newImage
            filterWasApplied = true
            showsOriginal = false
            compareButton.enabled = true
            if sender.titleLabel!.text! == "Saturation" {
                editButton.enabled = true
            }//if
            else {
                editButton.enabled = false
            }//else
            hideFilterCollection()
        }
    }
    
    @IBAction func compareImages(sender: UIButton) {
        if filterWasApplied {
            if !showsOriginal {
                showsOriginal = true
                originalLabelView.hidden = false
                UIView.animateWithDuration(0.4) {
                    self.secondaryImageView.alpha = 1
                }
                if sender.titleLabel!.text == "Compare" {
                    sender.selected = true
                }//if sender is 'compare button'
                
            }//if filtered image is present
            else {
                if compareButton.selected == true && sender.titleLabel!.text != "Compare" {
                    return
                }//if
                UIView.animateWithDuration(0.4) {
                    self.secondaryImageView.alpha = 0
                }
                showsOriginal = false
                originalLabelView.hidden = true
                if sender.titleLabel!.text == "Compare" {
                    sender.selected = false
                }//if sender is 'compare button'
            }//else if original image is present
        }//if filterWasApplied
    }
    
//----------------------------------------------Collection View methods----------------------------------------------
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return availableFilters.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = filterCollection.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! FilterCellCollection
        let filterName = availableFilters[indexPath.section]
        cell.filterName.text = filterName
        cell.filterButton.setTitle(filterName, forState: UIControlState.Normal)
        cell.filterSample.image = filteredImageForCollectionViewCell(filterName)
        cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.65)
        return cell
    }
    
    func filteredImageForCollectionViewCell(name: String) -> UIImage? {
        let scaledImage = resizedImage(imageView.image!, toSize: CGSizeMake(75, 75))
        let imageProcessor = ImageProcessor(image: RGBAImage(image: scaledImage)!)
        if let newImage = imageProcessor.findAndApplyFilter(name) {
            return newImage
        }//if
        else {
            return nil
        }//else
    }
    
    
    func showFilterCollection() {
        if editButton.selected {
            hideEditSlider()
            editButton.selected = false
        }
        filterCollection.reloadData()
        filterCollection.hidden = false
        filterCollection.alpha = 0
        screenCompareButton.enabled = false
        UIView.animateWithDuration(0.4) {
            self.filterCollection.alpha = 1.0
        }
    }
    
    func hideFilterCollection() {
        screenCompareButton.enabled = true
        UIView.animateWithDuration(0.4, animations: {
            self.filterCollection.alpha = 0
            }) { completed in
                if completed == true {
                    self.filterCollection.hidden = true
                    self.filterButton.selected = false
                }
        }
    }
    
    func resizedImage(image:UIImage, toSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    

}

