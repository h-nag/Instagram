//
//  SettingViewController.swift
//  Instagram
//
//  Created by Hilarion on 2016/06/02.
//  Copyright © 2016年 hidenori.nagasawa. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
// import SVProgressHUD
import MBProgressHUD

class SettingViewController: UIViewController {

    @IBOutlet weak var displayNameTextField: UITextField!
    
    
    @IBAction func handleChangeButton(sender: AnyObject) {
        
        
        if let name = displayNameTextField.text {
            // 表示名が入力されていない時はHUDを出して何もしない
            if name.characters.isEmpty {
                // SVProgressHUD.showErrorWithStatus("表示名を入力してください")
                return
            }
            
            if let request = FIRAuth.auth()?.currentUser?.profileChangeRequest() {
                
                request.displayName = name
                request.commitChangesWithCompletion() {error in
                    if error != nil {
                        // エラー表示
                        print("登録失敗")
                        print(error)
                    
                    } else {
                        // NSUserDefaultsに表示名を保存する
                        let ud = NSUserDefaults.standardUserDefaults()
                        ud.setValue(name, forKey: CommonConst.DisplayNameKey)
                        ud.synchronize()
                        
                        // HUDで完了を知らせる
                        // SVProgressHUD.showSuccessWithStatus("表示名を変更しました")
                        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        hud.mode = MBProgressHUDMode.Text
                        hud.labelText = "表示名を変更しました"
                        
                        // キーボードを閉じる
                        self.view.endEditing(true)
                    }
                }
            }
        }
    }
    @IBAction func handleLogoutButton(sender: AnyObject) {
        
        // ログアウトする
        try! FIRAuth.auth()?.signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
        self.presentViewController(loginViewController!, animated: true, completion: nil)
        
        // ログイン画面から戻ってきた時のためにホーム画面(index = 0)を選択していく状態にする
        let tabBarController = parentViewController as! ESTabBarController
        tabBarController.setSelectedIndex(0, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NSUserDefaultsから表示名を取得してTextFieldに設定する
        let ud = NSUserDefaults.standardUserDefaults()
        let name = ud.objectForKey(CommonConst.DisplayNameKey) as! String
        
        displayNameTextField.text = name
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
