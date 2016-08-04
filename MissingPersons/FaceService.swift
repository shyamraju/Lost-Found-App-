//
//  FaceService.swift
//  MissingPersons
//
//  Created by Shyam Raju on 6/24/16.
//  Copyright © 2016 Shyam Raju. All rights reserved.
//

import Foundation
import ProjectOxfordFace

class FaceService {
    static let instance = FaceService()
    
    let client = MPOFaceServiceClient(subscriptionKey: "71af2282c97540e2adea3c20b725b636")
}