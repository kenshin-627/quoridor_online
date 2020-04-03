//
//  ViewController.swift
//  QuoridorOnline
//
//  Created by フジタケンシン on 2020/03/04.
//  Copyright © 2020 Kenshin Fujita. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class ViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var offLineButton: UIButton!
    @IBOutlet weak var onLineButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var roomNumberTextField: UITextField!
    
    @IBOutlet weak var showStatusLabel: UILabel!
    
    var hudState = 0 // PKHUDのインディケーターが回っているか 0:回ってない, 1:回ってる
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        roomNumberTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStatusLabel.text = ""
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userNameTextField.text = (UserDefaults.standard.object(forKey: "userName") as! String)
        }
        if UserDefaults.standard.object(forKey: "roomNumber") != nil{
            roomNumberTextField.text = (UserDefaults.standard.object(forKey: "roomNumber") as! String)
        }
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
        UserDefaults.standard.set(roomNumberTextField.text, forKey: "roomNumber")
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
        UserDefaults.standard.set(roomNumberTextField.text, forKey: "roomNumber")
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func goOnLine(_ sender: Any) {
        UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
        UserDefaults.standard.set(roomNumberTextField.text, forKey: "roomNumber")
        showStatusLabel.text = ""
        if userNameTextField.text == "" || roomNumberTextField.text == "" || userNameTextField.text!.count > 5{
            // user name か room number が設定されていなかったらアラートを表示する
            let alert = UIAlertController(title: "5文字以下の user name と room number を設定してください", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }else{
            // オンライン対戦のデータベース
            let roomsDB = Database.database().reference().child("rooms")
            
            // オンライン対戦の自分の部屋のデータベース
            let myRoomDB = roomsDB.child(self.roomNumberTextField.text!)
            
            // user name と room number が設定されていたらFirebaseに匿名ログイン
            Auth.auth().signInAnonymously { (authResult, error) in
                // エラーならエラー内容を表示して処理を終了
                if error != nil{
                    print(error as Any)
                    self.showStatusLabel.text = (error.debugDescription)
                    return
                }
                
                // インディケーターを回す 40秒たってもインディケーターが止まっていなかったら処理を中断してインディケーターを止める
                HUD.flash(.progress, onView: self.view, delay: 40) { (_) in
                    self.hudState = 0
                    myRoomDB.removeValue()
                    self.showStatusLabel.text = "対戦相手が見つかりませんでした"
                }
                self.hudState = 1
                
                
                // 0人ならルームに入って待機
                // 1人ならルームに入って対戦開始(画面遷移)
                // 2人以上ならエラー内容を表示
                myRoomDB.observe(.value) { (snapShot) in
                    myRoomDB.removeAllObservers()
                    var standardX = 0
                    var standardY = 0
                    let height = UIScreen.main.bounds.size.height
                    if height == 667 {
                        standardX = 0
                        standardY = 0
                        //iPhone6,6s,7,8
                    }else if height == 736 {
                        standardX = 20
                        standardY = 14
                        //iPhone6+,6s+,7+,8Plus
                    }else if height == 812{
                        standardX = 0
                        standardY = 52
                        //iPhoneX,XS,11Pro
                    }else if height == 896{
                        standardX = 20
                        standardY = 94
                        //iPhoneXR,XSMax,11,11ProMax
                    }else{
                        print("この機種には対応していません")
                    }
                    let snapShotDate = snapShot.value as AnyObject
                    let numberOfPeople = snapShotDate.value(forKey: "numberOfPeople") as? String
                    if numberOfPeople == nil{
                        myRoomDB.child("numberOfPeople").setValue("1")
                        myRoomDB.child("p1StandardX").setValue(standardX)
                        myRoomDB.child("p1StandardY").setValue(standardY)
                        myRoomDB.child("p1Name").setValue(self.userNameTextField.text)
                        myRoomDB.observe(.value) { (snapShot) in
                            let snapShotDate = snapShot.value as AnyObject
                            let numberOfPeople = snapShotDate.value(forKey: "numberOfPeople") as? String
                            if numberOfPeople == "2"{
                                myRoomDB.removeAllObservers()
                                self.hudState = 0
                                HUD.hide()
                                self.performSegue(withIdentifier: "onLine", sender: nil)
                            }
                        }
                    }else if numberOfPeople == "1"{
                        if (snapShotDate.value(forKey: "p1Name") as! String) == self.userNameTextField.text{
                            self.showStatusLabel.text = "このuser nameは使用できません"
                            self.hudState = 0
                            HUD.hide()
                            return
                        }
                        myRoomDB.child("p2Name").setValue(self.userNameTextField.text)
                        myRoomDB.child("p2StandardX").setValue(standardX)
                        myRoomDB.child("p2StandardY").setValue(standardY)
                        myRoomDB.child("wasTurnPlayer").setValue("p2")
                        myRoomDB.child("numberOfPeople").setValue("2")
                        self.hudState = 0
                        HUD.hide()
                        self.performSegue(withIdentifier: "onLine", sender: nil)
                    }else if numberOfPeople == "2"{
                        self.hudState = 0
                        HUD.hide()
                        self.showStatusLabel.text = "この部屋は使用中です"
                    }
                }
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let onLineVC = segue.destination as! OnLineViewController
//    }
    
}
