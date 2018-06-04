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
        guard let photoData = UIImageJPEGRepresentation(photo, 0.7) else {
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
        guard let url = URL(string: "https://api.kairos.com/detect") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("48f9a54e", forHTTPHeaderField: "app_id")
        request.addValue("f9da2200327fdab7f1848c77ced880df", forHTTPHeaderField: "app_key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = ["image" : photoURL]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData
        let dataTask = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, urlResponse, error) in
            
            guard let responseData = data else {
                print(error as? String ?? "no error")
                completion(false)
                return
            }
            guard let results = try? JSONSerialization.jsonObject(with: responseData, options: []) else {
                print("JSON results ERROR")
                completion(false)
                return
            }
            print(results)
            completion(true)
        }
        dataTask.resume()
    }
    
}
