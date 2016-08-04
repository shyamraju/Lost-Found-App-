//
//  ViewController.swift
//  MissingPersons
//
//  Created by Shyam Raju on 6/23/16.
//  Copyright © 2016 Shyam Raju. All rights reserved.
//

import UIKit
import ProjectOxfordFace
import MBProgressHUD
var faceIdnew:String = ""
let baseURL = "https://missin.herokuapp.com/img/"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var textLabela: UILabel!
    
    
    var selectedPerson: Person?
    var hasSelectedImage: Bool = false
    let imagePicker = UIImagePickerController()
    
    
    
    let missingPeople = [
        Person(personImageUrl: "person1.jpg"),
        Person(personImageUrl: "person2.jpg"),
        Person(personImageUrl: "person3.jpg"),
        Person(personImageUrl: "person4.jpg"),
        Person(personImageUrl: "person5.jpg"),
        Person(personImageUrl: "person6.png")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.loadPicker(_:)))
        tap.numberOfTapsRequired = 1
        selectedImg.addGestureRecognizer(tap)
        //collectionView.allowsMultipleSelection = true;
    }
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return missingPeople.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // so kur da napisam ovde
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PersonCell", forIndexPath: indexPath) as! PersonCell
        
        //cell.selected = true
        //collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        
        let person = missingPeople[indexPath.row]
        cell.configureCell(person)
        return cell
    }
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedPerson = missingPeople[indexPath.row]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PersonCell
        cell.configureCell(selectedPerson!)
        cell.setSelected()
        let selecc=Int(indexPath.row+1)
        self.textLabela.text="Person "+String(selecc)
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedPerson = missingPeople[indexPath.row]
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PersonCell
        cell.configureCell(selectedPerson!)
        cell.setDeselected()
        let selecc=Int(indexPath.row+1)
        self.textLabela.text="Person "+String(selecc)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImg.image = pickedImage
            hasSelectedImage = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Select Person & Image", message: "Please select a missing person to check and an image", preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadPicker(gesture: UITapGestureRecognizer) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary // .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func checkMatch(sender: AnyObject) {
        print("Higher Quality Image Required!!")
        if selectedPerson == nil || !hasSelectedImage {
            showErrorAlert()
        } else {
            if let myImg = selectedImg.image, let imgData = UIImageJPEGRepresentation(myImg, 0.8) {
                // print("TESTING")
                //print(selectedImg.image)
                //print(selectedImg)
                //print("TESTING")
                let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.Indeterminate
                loadingNotification.labelText = "Loading"
                
                FaceService.instance.client.detectWithData(imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces:[MPOFace]!, err: NSError!)  in
                    
                    if err == nil {
                        var faceId: String?
                        for face in faces {
                            faceId = face.faceId
                            break
                        }
                        if faceId != nil {
                            FaceService.instance.client.verifyWithFirstFaceId(self.selectedPerson?.faceId, faceId2: faceId, completionBlock: { (result:MPOVerifyResult!, err:NSError!) in
                                if err == nil {
                                    print(result.confidence)
                                    print(result.isIdentical)
                                    print(result.debugDescription)
                                    if result.isIdentical == true {
                                        let alertController = UIAlertController(title: "HURRAY!!!", message:
                                            "FOUND!"+"\nConfidence : "+String(Double(result.confidence)*100)+"%"+"\nMatch : "+String(result.isIdentical), preferredStyle: UIAlertControllerStyle.Alert)
                                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                        
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        //self.textLabela.text = "YES"
                                        //self.textLabela.text=String(result.debugDescription)
                                    }else if result.isIdentical == false {
                                        
                                        let alertController = UIAlertController(title: "AWWW SNAP!", message:
                                            "NOT FOUND!"+"\nConfidence : "+String(Double(result.confidence)*100)+"%"+"\nMatch : "+String(result.isIdentical), preferredStyle: UIAlertControllerStyle.Alert)
                                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                        
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        //self.textLabela.text = "NO"
                                        //self.text2.text="NO"
                                    }
                                }else {
                                    
                                    print(err.debugDescription)
                                }
                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            })
                            
                        }
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        
                    }
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            }
        }
    }
    
    
    
    @IBAction func checkMatch1(sender: AnyObject) {
        if selectedPerson == nil || !hasSelectedImage {
            showErrorAlert()
        } else {
            if let myImg = selectedImg.image, let imgData = UIImageJPEGRepresentation(myImg, 0.8) {
                
                let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.Indeterminate
                loadingNotification.labelText = "Loading"
                
                FaceService.instance.client.detectWithData(imgData, returnFaceId: true, returnFaceLandmarks: false, returnFaceAttributes: nil, completionBlock: { (faces:[MPOFace]!, err: NSError!)  in
                    
                    if err == nil {
                        var faceId: String?
                        for face in faces {
                            faceId = face.faceId
                            break
                        }
                        if faceId != nil {
                            FaceService.instance.client.verifyWithFirstFaceId(self.selectedPerson?.faceId, faceId2: faceId, completionBlock: { (result:MPOVerifyResult!, err:NSError!) in
                                if err == nil {
                                    print(result.confidence)
                                    print(result.isIdentical)
                                    print(result.debugDescription)
                                    if result.isIdentical == true {
                                        let alertController = UIAlertController(title: "HURRAY!!!", message:
                                            "FOUND!"+"\nConfidence : "+String(Double(result.confidence)*100)+"%"+"\nMatch : "+String(result.isIdentical), preferredStyle: UIAlertControllerStyle.Alert)
                                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                        
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        //self.textLabela.text = "YES"
                                        //self.textLabela.text=String(result.debugDescription)
                                    }else if result.isIdentical == false {
                                        
                                        let alertController = UIAlertController(title: "AWWW SNAP!", message:
                                            "NOT FOUND!"+"\nConfidence : "+String(Double(result.confidence)*100)+"%"+"\nMatch : "+String(result.isIdentical), preferredStyle: UIAlertControllerStyle.Alert)
                                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                        
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        //self.textLabela.text = "NO"
                                        //self.text2.text="NO"
                                    }
                                }else {
                                    
                                    print(err.debugDescription)
                                }
                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            })
                            
                        }
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        
                    }
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                })
            }
        }
    }
    
    
    
}

