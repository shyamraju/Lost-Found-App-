//
//  PersonCell.swift
//  MissingPersons
//
//  Created by Shyam Raju on 6/23/16.
//  Copyright © 2016 Shyam Raju. All rights reserved.
//


import UIKit

class PersonCell: UICollectionViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    var person: Person!
    
    
    
    func configureCell(person: Person) {
        self.person = person
        self.addOrRemoveBorder()
        if let url = NSURL(string: "\(baseURL)\(person.personImageUrl!)") {
            downloadImage(url)
            
            
        }
    }
    
    func downloadImage(url: NSURL) {
        getDataFromUrl(url) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.personImage.image = UIImage(data: data)
                self.person.personImage = self.personImage.image
                
            }
        }
        
    }
    
    func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error:NSError?) ->Void)){
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
        
    }
    
    func addOrRemoveBorder() {
        if self.person.isSelected == true {
            personImage.clipsToBounds = false
            personImage.layer.borderWidth = 2.0
            personImage.layer.borderColor = UIColor.blueColor().CGColor
            
            
            
        } else if self.person.isSelected == false{
            personImage.layer.borderColor = UIColor.whiteColor().CGColor
            personImage.layer.borderWidth = 2.0
            
        }
    }
    
    func setSelected() {
        self.person.isSelected = true
        self.addOrRemoveBorder()
        self.person.downloadFaceId()
        
    }
    func setDeselected() {
        personImage.layer.borderColor = UIColor.whiteColor().CGColor
        personImage.layer.borderWidth = 2.0
        
    }
    
    
}

