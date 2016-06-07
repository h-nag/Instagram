//
//  PostData.swift
//  Instagram
//
//  Created by Hilarion on 2016/06/05.
//  Copyright © 2016年 hidenori.nagasawa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class  PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: NSDate?
    var likes: [String] = []
    var isLiked: Bool = false
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        id = snapshot.key
        
        imageString = snapshot.value?.objectForKey("image") as? String
        image = UIImage(data: NSData(base64EncodedString: imageString!, options: .IgnoreUnknownCharacters)!)
        
        name = snapshot.value?.objectForKey("name") as? String
        caption = snapshot.value?.objectForKey("caption") as? String
        
        if let likes = snapshot.value?.objectForKey("likes") as? [String] {
            self.likes = likes
        }
        
        for likedId in likes {
            if likedId == myId {
                isLiked = true
                break
            }
        }
        
        self.date = NSDate(timeIntervalSinceReferenceDate: snapshot.value?.objectForKey("time") as! NSTimeInterval)
    }
}