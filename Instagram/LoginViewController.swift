//
//  LoginViewController.swift
//  Instagram
//
//  Created by Hilarion on 2016/06/02.
//  Copyright © 2016年 hidenori.nagasawa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
// import SVProgressHUD
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    var firebaseRef: FIRDatabaseReference!
    var firebaseAuth: FIRAuth!
   
    // ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(sender: AnyObject) {
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時はHUDを出して何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.mode = MBProgressHUDMode.Text
                hud.labelText = "必要項目を入力してください。"
               // SVProgressHUD.showErrorWithStatus("必要項目を入力してください。")
                return
            }
            
            // 処理中を表示
            // SVProgressHUD.show()
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Indeterminate
            hud.show(true)
            
            firebaseAuth.signInWithEmail(address, password: password) {user, error in
                if error != nil {
                    // エラーを表示
                    print(error)
                } else {
                    // Firebaseからログインしたユーザの表示名を取得してNSUserDefaultsに保存する
                    if let displayName = user?.displayName {
                        
                        self.setDisplayName(displayName)
                    }
                }
                
                // HUDを消す
                // SVProgressHUD.dismiss()
                hud.hide(true)
                
                // 画面を閉じる
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(sender: AnyObject) {
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text,
            let displayName = displayNameTextField.text {
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty
                || displayName.characters.isEmpty{
            
                return
            }
            
            // 処理中を表示
           // SVProgressHUD.show()
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = MBProgressHUDMode.Indeterminate
            hud.show(true)
            
            firebaseAuth.createUserWithEmail(address, password: password, completion: {error, result in
                if error != nil {
                    print(error)
                } else {
                    // ユーザを作成できたらそのままログインする
                    self.firebaseAuth.signInWithEmail(address, password: password) {user, error in
                        if error != nil {
                            print(error)
                        } else {
                            // Firebaseに表示名を保存する
                            let request = user?.profileChangeRequest()
                            request?.displayName = displayName
                            request?.commitChangesWithCompletion({ error in
                                if error != nil {
                                    print(error)
                                } else {
                                    // NSUserDefaultsに表示名を保存する
                                    self.setDisplayName(displayName)
                                    // 画面を閉じる
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            })
                            

                            
                            // HUDを消す
                           // SVProgressHUD.dismiss()
                            hud.hide(true)

                        }
                    }
                }
            })
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebaseを初期化する
        firebaseRef = FIRDatabase.database().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // NSUserDefaultsに表示名保存する
    func setDisplayName(name: String){
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setValue(name, forKey: CommonConst.DisplayNameKey)
        ud.synchronize()
    }
    
}
