//
//  HomeViewController.swift
//  Instagram
//
//  Created by Hilarion on 2016/06/02.
//  Copyright © 2016年 hidenori.nagasawa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var firedaseRef: FIRDatabaseReference!
    var postArray: [PostData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UITableViewを準備する
        let nib = UINib(nibName: "PostTabelViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Firebaseの準備する
        firedaseRef = FIRDatabase.database().reference()
        
        // 要素が追加されたらpostArrayに追加してTableVieを再表示させる
        firedaseRef.child(CommonConst.PostPATH).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                self.postArray.insert(postData, atIndex: 0)
            
            
            // TableViewを再表示する
            self.tableView.reloadData()
            }
        })
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示させる
        firedaseRef.child(CommonConst.PostPATH).observeEventType(.ChildChanged, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                
                // 保持している配列からidが同じものを探す
                var index: Int = 0
                for post in self.postArray {
                    if post.id == postData.id {
                        index = self.postArray.indexOf(post)!
                        break
                    }
                }
                
                // 差し替えるため一度削除する
                self.postArray.removeAtIndex(index)
                
                // 削除した箇所に更新済みのデータを追加する
                self.postArray.insert(postData, atIndex: index)
                
                // TableViewの該当セルだけを更新する
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        cell.postData = postArray[indexPath.row]
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action: #selector(HomeViewController.handleButton(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // UILabelの行数が変わってる可能せがあるので再描画させる
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // AutoLayoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // セルをタップされたら何もせずに選択状態を解除す
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    // セル内のボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = FIRAuth.auth()?.currentUser?.uid {
        
        if postData.isLiked {
            // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
            var index = -1
            for likeId in postData.likes {
                if likeId == uid {
                    
                // 削除するためにインデックスを保持しておく
                index = postData.likes.indexOf(likeId)!
                break
            }
        }
            postData.likes.removeAtIndex(index)
        } else {
            postData.likes.append(uid)
        }
        
            let imageString = postData.imageString
            let name = postData.name
            let caption = postData.caption
            let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
            let likes = postData.likes
            
            // 辞書を作成してFirebaseに保存する
            let post = ["caption": caption!, "imageString": imageString!, "name": name!, "time": time, "likes": likes]
            let postRef = FIRDatabase.database().reference()
            postRef.child(CommonConst.PostPATH).child(postData.id!).setValue(post)
        }
    }

}
