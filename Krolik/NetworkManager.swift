//
//  NetworkManager.swift
//  Krolik
//
//  Created by Colin on 2018-06-01.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import UIKit
import FirebaseStorage

class NetworkManager {
    
    func uploadPhoto(photo: UIImage, path: String, completion: @escaping (_ photoURL: URL, Error?) -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        guard let photoData = UIImagePNGRepresentation(photo) else {
            print("photo data conversion ERROR")
            return
        }
        
        let photoRef = storageRef.child(path)
        let _ = photoRef.putData(photoData, metadata: nil) { (metadata, error) in
            photoRef.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    print("ERROR getting photo url from Firebase")
                    return
                }
                completion(downloadURL, error)
            })
        }
    }
    
    func checkPhotoFace(photoURL: String, completion: @escaping (_ isFace: Bool) -> ()) {
        
    }
    
}
