//
//  OnLineViewController.swift
//  QuoridorOnline
//
//  Created by フジタケンシン on 2020/03/12.
//  Copyright © 2020 Kenshin Fujita. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

/*
 自分のターンにすることは
 ・移動する
 ・壁を置く
 ・降参する
 この三つの行動
 ・移動した時は自分の現在地(p1NowPlaceまたはp2NowPlace)を送る
 ・壁を置いた時は壁を置いた場所(dropWallPlace)と方向(dropWallVorH)を送る
 ・降参した時はそのまま
 と、このターンの行動(nowTurnAction:moveまたはdropWallまたはsurrender)
 最後にこのターン行動したプレイヤー(wasTurnPlayer:自分または相手の名前)
 をデータベースに送る
 
 データベースが更新された時は
 まず、wasTurnPlayerがローカルに保存してあるものと同じかどうか見る
 同じなら何もしないで終わる
 違うならローカルのwasTurnPlayerを更新する
 wasTurnPlayerが自分なら何もしない
 wasTurnPlayerが相手ならnowTurnActionを確認する
 ・surrenderなら勝利画面を表示
 ・moveなら相手の現在地を相手のnowPlaceに移動
 ・dropWallならdropWallPlaceの位置にdropWallVorHの方向の相手の色の壁を置く
 それが終わったら、turnChange!
 */
class OnLineViewController: UIViewController, UIDragInteractionDelegate, UIDropInteractionDelegate, GADInterstitialDelegate {
    
    // 名前を表示するラベル
    @IBOutlet weak var p1NameLabel: UILabel!
    @IBOutlet weak var p2NameLabel: UILabel!
    
    // 残りの壁の所持数を表示するラベル
    @IBOutlet weak var p1WallCountLabel: UILabel!
    @IBOutlet weak var p2WallCountLabel: UILabel!
    
    // 移動をやめるキャンセルボタン
    @IBOutlet weak var p1CancelButton: UIButton!
    @IBOutlet weak var p2CancelButton: UIButton!
    
    // ドラッグアンドドロップで置く壁のビュー
    // 垂直方向がV(vertical), 水平方向がH(Horizontal)
    @IBOutlet weak var p1VWallView: UIView!
    @IBOutlet weak var p2VWallView: UIView!
    @IBOutlet weak var p1HWallView: UIView!
    @IBOutlet weak var p2HWallView: UIView!
    
    // 降参するボタン
    @IBOutlet weak var surrenderButton: UIButton!
    
    // 横a,b,... 縦1,2,...
    /*
     a1 b1 ...
     a2 b2 ...
     ...
     */
    // ボタン 1行目
    @IBOutlet weak var a1Button: UIButton!
    @IBOutlet weak var b1Button: UIButton!
    @IBOutlet weak var c1Button: UIButton!
    @IBOutlet weak var d1Button: UIButton!
    @IBOutlet weak var e1Button: UIButton!
    @IBOutlet weak var f1Button: UIButton!
    @IBOutlet weak var g1Button: UIButton!
    @IBOutlet weak var h1Button: UIButton!
    @IBOutlet weak var i1Button: UIButton!
    // 2行目
    @IBOutlet weak var a2Button: UIButton!
    @IBOutlet weak var b2Button: UIButton!
    @IBOutlet weak var c2Button: UIButton!
    @IBOutlet weak var d2Button: UIButton!
    @IBOutlet weak var e2Button: UIButton!
    @IBOutlet weak var f2Button: UIButton!
    @IBOutlet weak var g2Button: UIButton!
    @IBOutlet weak var h2Button: UIButton!
    @IBOutlet weak var i2Button: UIButton!
    // 3行目
    @IBOutlet weak var a3Button: UIButton!
    @IBOutlet weak var b3Button: UIButton!
    @IBOutlet weak var c3Button: UIButton!
    @IBOutlet weak var d3Button: UIButton!
    @IBOutlet weak var e3Button: UIButton!
    @IBOutlet weak var f3Button: UIButton!
    @IBOutlet weak var g3Button: UIButton!
    @IBOutlet weak var h3Button: UIButton!
    @IBOutlet weak var i3Button: UIButton!
    // 4行目
    @IBOutlet weak var a4Button: UIButton!
    @IBOutlet weak var b4Button: UIButton!
    @IBOutlet weak var c4Button: UIButton!
    @IBOutlet weak var d4Button: UIButton!
    @IBOutlet weak var e4Button: UIButton!
    @IBOutlet weak var f4Button: UIButton!
    @IBOutlet weak var g4Button: UIButton!
    @IBOutlet weak var h4Button: UIButton!
    @IBOutlet weak var i4Button: UIButton!
    // 5行目
    @IBOutlet weak var a5Button: UIButton!
    @IBOutlet weak var b5Button: UIButton!
    @IBOutlet weak var c5Button: UIButton!
    @IBOutlet weak var d5Button: UIButton!
    @IBOutlet weak var e5Button: UIButton!
    @IBOutlet weak var f5Button: UIButton!
    @IBOutlet weak var g5Button: UIButton!
    @IBOutlet weak var h5Button: UIButton!
    @IBOutlet weak var i5Button: UIButton!
    // 6行目
    @IBOutlet weak var a6Button: UIButton!
    @IBOutlet weak var b6Button: UIButton!
    @IBOutlet weak var c6Button: UIButton!
    @IBOutlet weak var d6Button: UIButton!
    @IBOutlet weak var e6Button: UIButton!
    @IBOutlet weak var f6Button: UIButton!
    @IBOutlet weak var g6Button: UIButton!
    @IBOutlet weak var h6Button: UIButton!
    @IBOutlet weak var i6Button: UIButton!
    // 7行目
    @IBOutlet weak var a7Button: UIButton!
    @IBOutlet weak var b7Button: UIButton!
    @IBOutlet weak var c7Button: UIButton!
    @IBOutlet weak var d7Button: UIButton!
    @IBOutlet weak var e7Button: UIButton!
    @IBOutlet weak var f7Button: UIButton!
    @IBOutlet weak var g7Button: UIButton!
    @IBOutlet weak var h7Button: UIButton!
    @IBOutlet weak var i7Button: UIButton!
    // 8行目
    @IBOutlet weak var a8Button: UIButton!
    @IBOutlet weak var b8Button: UIButton!
    @IBOutlet weak var c8Button: UIButton!
    @IBOutlet weak var d8Button: UIButton!
    @IBOutlet weak var e8Button: UIButton!
    @IBOutlet weak var f8Button: UIButton!
    @IBOutlet weak var g8Button: UIButton!
    @IBOutlet weak var h8Button: UIButton!
    @IBOutlet weak var i8Button: UIButton!
    // 9行目
    @IBOutlet weak var a9Button: UIButton!
    @IBOutlet weak var b9Button: UIButton!
    @IBOutlet weak var c9Button: UIButton!
    @IBOutlet weak var d9Button: UIButton!
    @IBOutlet weak var e9Button: UIButton!
    @IBOutlet weak var f9Button: UIButton!
    @IBOutlet weak var g9Button: UIButton!
    @IBOutlet weak var h9Button: UIButton!
    @IBOutlet weak var i9Button: UIButton!
    
    // ビュー 1行目
    @IBOutlet weak var a1View: UIView!
    @IBOutlet weak var b1View: UIView!
    @IBOutlet weak var c1View: UIView!
    @IBOutlet weak var d1View: UIView!
    @IBOutlet weak var e1View: UIView!
    @IBOutlet weak var f1View: UIView!
    @IBOutlet weak var g1View: UIView!
    @IBOutlet weak var h1View: UIView!
    // 2行目
    @IBOutlet weak var a2View: UIView!
    @IBOutlet weak var b2View: UIView!
    @IBOutlet weak var c2View: UIView!
    @IBOutlet weak var d2View: UIView!
    @IBOutlet weak var e2View: UIView!
    @IBOutlet weak var f2View: UIView!
    @IBOutlet weak var g2View: UIView!
    @IBOutlet weak var h2View: UIView!
    // 3行目
    @IBOutlet weak var a3View: UIView!
    @IBOutlet weak var b3View: UIView!
    @IBOutlet weak var c3View: UIView!
    @IBOutlet weak var d3View: UIView!
    @IBOutlet weak var e3View: UIView!
    @IBOutlet weak var f3View: UIView!
    @IBOutlet weak var g3View: UIView!
    @IBOutlet weak var h3View: UIView!
    // 4行目
    @IBOutlet weak var a4View: UIView!
    @IBOutlet weak var b4View: UIView!
    @IBOutlet weak var c4View: UIView!
    @IBOutlet weak var d4View: UIView!
    @IBOutlet weak var e4View: UIView!
    @IBOutlet weak var f4View: UIView!
    @IBOutlet weak var g4View: UIView!
    @IBOutlet weak var h4View: UIView!
    // 5行目
    @IBOutlet weak var a5View: UIView!
    @IBOutlet weak var b5View: UIView!
    @IBOutlet weak var c5View: UIView!
    @IBOutlet weak var d5View: UIView!
    @IBOutlet weak var e5View: UIView!
    @IBOutlet weak var f5View: UIView!
    @IBOutlet weak var g5View: UIView!
    @IBOutlet weak var h5View: UIView!
    // 6行目
    @IBOutlet weak var a6View: UIView!
    @IBOutlet weak var b6View: UIView!
    @IBOutlet weak var c6View: UIView!
    @IBOutlet weak var d6View: UIView!
    @IBOutlet weak var e6View: UIView!
    @IBOutlet weak var f6View: UIView!
    @IBOutlet weak var g6View: UIView!
    @IBOutlet weak var h6View: UIView!
    // 7行目
    @IBOutlet weak var a7View: UIView!
    @IBOutlet weak var b7View: UIView!
    @IBOutlet weak var c7View: UIView!
    @IBOutlet weak var d7View: UIView!
    @IBOutlet weak var e7View: UIView!
    @IBOutlet weak var f7View: UIView!
    @IBOutlet weak var g7View: UIView!
    @IBOutlet weak var h7View: UIView!
    // 8行目
    @IBOutlet weak var a8View: UIView!
    @IBOutlet weak var b8View: UIView!
    @IBOutlet weak var c8View: UIView!
    @IBOutlet weak var d8View: UIView!
    @IBOutlet weak var e8View: UIView!
    @IBOutlet weak var f8View: UIView!
    @IBOutlet weak var g8View: UIView!
    @IBOutlet weak var h8View: UIView!
    
    // プレイヤー1,2
    var p1: Player!
    var p2: Player!
    
    // 自分はプレイヤー1か2か
    var iAm: Player!
    // Stringバージョン
    var iAmString = String()
    
    // ボタンの配列
    var buttons = [UIButton]()
    
    // ビューの配列
    var views = [UIView]()
    
    /* それぞれのUIViewに壁が置かれている(縦:V, 横:H)か置かれていない("")か
       ボタンと対応させるために一行につき10個作って最後の2個は""
       最初(1行目)と最後(10行目)の行は空白
     例)
     -|-|- -|
     - -  --|
     dropWallVorH =
     ["","H","H","H","H","H","H","H","H", "",
     "V","H","V","H","V","H", "","H","V","V",
     "V","H", "","H", "", "","H","H","V","V",
     "V", "", "", "", "", "", "", "", "","V",
      ...
      "","H","H","H","H","H","H","H","H", "",
     要素数 10x10, 0~99
     */
    var dropWallVorH = [String]()
    
    // 壁がドロップされたUVIewのtag
    var dropViewTag = Int()
    
    // 壁がドロップされたUIViewのx座標,y座標
    var dropViewX = CGFloat()
    var dropViewY = CGFloat()
    
    // ドラッグしている壁が縦か横か 縦:V, 横:H
    var vOrH = String()
    
    // 今どっちのターンか p1かp2
    var nowTurn: Player!
    // 次どっちのターンか
    var nextTurn: Player!
    
    // インタースティシャル広告
    var interstitial: GADInterstitial!
    
    // どちらのプレイヤーが行動したか、データベースと共有
    var wasTurnPlayer = "p2"
    
    // オンライン対戦の自分の部屋のデータベース
    let myRoomDB = Database.database().reference().child("rooms").child(UserDefaults.standard.object(forKey: "roomNumber") as! String)
    
    // 自分の現在地のデータベース
    var myNowPlaceDB: DatabaseReference!
    
    // 壁を置く際に各プレイヤーの機種の画面サイズに応じた場所に置くための基準となる変数
    var p1StandardX = Int()
    var p1StandardY = Int()
    var p2StandardX = Int()
    var p2StandardY = Int()
    
    var standardX = Int()
    var standardY = Int()
    

    
    // -------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // インタースティシャル広告の準備
        interstitial = createAndLoadInterstitial()
        
        // p1,p2を初期化
        p1 = Player(nowPlace: 85, wallCount: 10, cancelButton: p1CancelButton, vWallView: p1VWallView, hWallView: p1HWallView)
        p2 = Player(nowPlace: 5, wallCount: 10, cancelButton: p2CancelButton, vWallView: p2VWallView, hWallView: p2HWallView)
        
        // p2の名前とp2の壁所持数ラベルとキャンセルボタンを180°回転させる
        p2NameLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        p2WallCountLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        p2.cancelButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)

        // 壁の色を設定する
        p1.vWallView.backgroundColor = .purple
        p1.hWallView.backgroundColor = .purple
        p2.vWallView.backgroundColor = .orange
        p2.hWallView.backgroundColor = .orange

        // 各ボタン、ビューを配列に格納
        storeButtonAndViewInArray()

        // 9x9の盤面を作成して周りに壁を作る
        dropWallVorH = Board(vertical: 9, horizontal: 9).createBoard()

        // 各ボタンを緑色に
        for button in buttons{
            button.backgroundColor = .green
        }

        // p1が先攻
        nowTurn = p1
        // p2が後攻
        nextTurn = p2

        // 現在地の画像を更新
        setImageNowPlace()

        // ターンプレイヤーの現在地以外のボタンは無効(ターンプレイヤーじゃなければ全ボタン無効)
        for button in buttons{
            if p1.nowPlace == nowTurn.nowPlace && button.tag == nowTurn.nowPlace{
                button.isEnabled = true
            }else{
                button.isEnabled = false
            }
        }

        // キャンセルボタンは無効にして非表示
        p1.cancelButton.isEnabled = false
        p1.cancelButton.isHidden = true
        p2.cancelButton.isEnabled = false
        p2.cancelButton.isHidden = true

        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        view.addInteraction(dragInteraction)

        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
        
        // p1,p2の名前と自分がどちらかを設定
        myRoomDB.observeSingleEvent(of: .value, with: { (snapShot) in
            print("A")
            let snapShotDate = snapShot.value as AnyObject
            let p1Name = snapShotDate.value(forKey: "p1Name") as! String
            let p2Name = snapShotDate.value(forKey: "p2Name") as! String
            self.p1StandardX = snapShotDate.value(forKey: "p1StandardX") as! Int
            self.p1StandardY = snapShotDate.value(forKey: "p1StandardY") as! Int
            self.p2StandardX = snapShotDate.value(forKey: "p2StandardX") as! Int
            self.p2StandardY = snapShotDate.value(forKey: "p2StandardY") as! Int
            self.p1NameLabel.text = p1Name
            self.p2NameLabel.text = p2Name
            if p1Name == UserDefaults.standard.object(forKey: "userName") as! String{
                self.iAm = self.p1
                self.iAmString = "p1"
                self.standardX = self.p1StandardX - self.p2StandardX
                self.standardY = self.p1StandardY - self.p2StandardY
            }else{
                self.iAm = self.p2
                self.iAmString = "p2"
                self.standardX = self.p2StandardX - self.p1StandardX
                self.standardY = self.p2StandardY - self.p1StandardY
                self.surrenderButton.isEnabled = false
                self.surrenderButton.isHidden = true
            }
            if self.iAm.nowPlace == self.p1.nowPlace{
                self.myNowPlaceDB = self.myRoomDB.child("p1NowPlace")
            }else{
                self.myNowPlaceDB = self.myRoomDB.child("p2NowPlace")
            }
        })
        
        myRoomDB.observe(.value) { (snapShot) in
            print("B")
            let snapShotData = snapShot.value as AnyObject
            let wasTurnPlayerData = snapShotData.value(forKey: "wasTurnPlayer") as! String
            if wasTurnPlayerData == self.wasTurnPlayer{
                print("C1")
                return
            }
            print("C2")
            self.wasTurnPlayer = wasTurnPlayerData
            if self.wasTurnPlayer == self.iAmString{
                print("D1")
                return
            }
            print("D2")
            let nowTurnAction = snapShotData.value(forKey: "nowTurnAction") as! String
            if nowTurnAction == "surrender"{
                print("surrender")
                self.myRoomDB.removeAllObservers()
                self.myRoomDB.removeValue()
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                print("win")
                button.setImage(UIImage(named: "youWin"), for: .normal)
                button.contentMode = .scaleToFill
                button.addTarget(self, action: #selector(self.backTitle(_:)), for: .touchUpInside)
                self.view.addSubview(button)
            }else if nowTurnAction == "move"{
                print("move")
                var enemyNowPlaceString = String()
                if self.iAmString == "p1"{
                    enemyNowPlaceString = "p2NowPlace"
                }else{
                    enemyNowPlaceString = "p1NowPlace"
                }
                let enemyNowPlace = snapShotData.value(forKey: enemyNowPlaceString) as! String
                // 現在地をそのマスに移す
                self.nowTurn.nowPlace = Int(enemyNowPlace)!
                if self.isGoal(){
                    self.showWinner()
                }
                // すべてのマスを緑色にし、現在地以外のボタンを無効にする
                for button in self.buttons{
                    button.backgroundColor = .green
                    button.isEnabled = false
                    if self.nextTurn.nowPlace == button.tag{
                        self.surrenderButton.isEnabled = true
                        self.surrenderButton.isHidden = false
                        button.isEnabled = true
                    }
                }
            }else if nowTurnAction == "dropWall"{
                print("dropWall")
                let wallView = UIView()
                var wallWidth = Int()
                var wallHeight = Int()
                let wallX = snapShotData.value(forKey: "dropWallPlaceX") as! Int
                let wallY = snapShotData.value(forKey: "dropWallPlaceY") as! Int
                let VorH = snapShotData.value(forKey: "dropWallVorH") as! String
                let dropViewTag = snapShotData.value(forKey: "dropViewTag") as! Int
                if VorH == "V"{
                    wallWidth = 10
                    wallHeight = 70
                }else{
                    wallWidth = 70
                    wallHeight = 10
                }
                wallView.frame = CGRect(x: wallX + self.standardX, y: wallY + self.standardY, width: wallWidth, height: wallHeight)
                self.nowTurn.wallCount -= 1
                if self.nowTurn.nowPlace == self.p1.nowPlace{
                    wallView.backgroundColor = .purple
                    self.p1WallCountLabel.text = String(self.p1.wallCount)
                }else{
                    wallView.backgroundColor = .orange
                    self.p2WallCountLabel.text = String(self.p2.wallCount)
                }
                self.dropWallVorH[dropViewTag] = VorH
                self.view.addSubview(wallView)
                // すべてのマスを緑色にし、現在地以外のボタンを無効にする
                for button in self.buttons{
                    button.backgroundColor = .green
                    button.isEnabled = false
                    if self.nextTurn.nowPlace == button.tag{
                        self.surrenderButton.isEnabled = true
                        self.surrenderButton.isHidden = false
                        button.isEnabled = true
                    }
                }
            }
            print("E")
            self.changeTurn()
            self.setImageNowPlace()
        }
    }
    //---------------------------------------------------------------
    
    func highlightCell(button: UIButton){
        // もし押されたボタンの場所がターンプレイヤーの現在地なら
        if isNowPlace(button: button, nowPlace: nowTurn.nowPlace){
            let goArray = canGoArray(nowPlace: nowTurn.nowPlace, enemyPlace: nextTurn.nowPlace)
            for button in buttons {
                for canGo in goArray{
                    if button.tag == canGo{
                        // 背景色を赤色にして有効にする
                        button.backgroundColor = .red
                        button.isEnabled = true
                    }
                }
            }
            // 現在地のボタンを無効にする
            button.isEnabled = false
            // キャンセルボタンを表示して有効にする
            nowTurn.cancelButton.isHidden = false
            nowTurn.cancelButton.isEnabled = true
        }else{
            // 押されたボタンの場所が現在地じゃない(ハイライトされている状態)なら
            // 現在地をそのマスに移す
            nowTurn.nowPlace = button.tag
            if isGoal(){
                showWinner()
            }
            // キャンセルボタンを無効にして非表示
            nowTurn.cancelButton.isEnabled = false
            nowTurn.cancelButton.isHidden = true
            // データベースに送信
            myNowPlaceDB.setValue(String(nowTurn.nowPlace))
            myRoomDB.child("nowTurnAction").setValue("move")
            myRoomDB.child("wasTurnPlayer").setValue(iAmString)
            // ターン交代
            changeTurn()
            surrenderButton.isEnabled = false
            surrenderButton.isHidden = true
            // すべてのマスを緑色にし、現在地以外のボタンを無効にする
            for button in buttons{
                button.backgroundColor = .green
                if isNowPlace(button: button, nowPlace: nowTurn.nowPlace){
                    // 現在地のボタンを有効にする
                    button.isEnabled = true
                }else{
                    // 現在地じゃないボタンを無効にする
                    button.isEnabled = false
                }
            }
            // 現在地の画像を更新し、他のマスの画像は消す
            setImageNowPlace()
        }
    }
    
    
    
    // 移動できるマスをInt型の配列にして返す
    func canGoArray(nowPlace: Int, enemyPlace: Int) -> [Int]{
        // 移動できるマスの配列
        var canGoPlaces = [Int]()
        // 現在地の上が壁でないなら
        if !isWall(direction: "上", nowPlace: nowPlace){
            // 現在地の上が敵でないなら配列に追加
            if !isEnemy(direction: "上"){
                canGoPlaces.append(nowPlace - 10)
            }else{// 現在地の上が敵なら
                // 敵の上が壁でないなら配列に追加
                if !isWall(direction: "上", nowPlace: enemyPlace){
                    canGoPlaces.append(nowPlace - 20)
                }else{// 敵の上が壁なら
                    // 敵の右が壁でないなら配列に追加
                    if !isWall(direction: "右", nowPlace: enemyPlace){
                        canGoPlaces.append(nowPlace - 10 + 1)
                    }
                    // 敵の左が壁でないなら配列に追加
                    if !isWall(direction: "左", nowPlace: enemyPlace){
                        canGoPlaces.append(nowPlace - 10 - 1)
                    }
                }
            }
        }
        // 現在地の下が壁でないなら
        if !isWall(direction: "下", nowPlace: nowTurn.nowPlace){
            // 現在地の下が敵でないなら配列に追加
            if !isEnemy(direction: "下"){
                canGoPlaces.append(nowTurn.nowPlace + 10)
            }else{// 現在地の下が敵なら
                // 敵の下が壁でないなら配列に追加
                if !isWall(direction: "下", nowPlace: nextTurn.nowPlace){
                    canGoPlaces.append(nowTurn.nowPlace + 20)
                }else{// 敵の下が壁なら
                    // 敵の右が壁でないなら配列に追加
                    if !isWall(direction: "右", nowPlace: nextTurn.nowPlace){
                        canGoPlaces.append(nowTurn.nowPlace + 10 + 1)
                    }
                    // 敵の左が壁でないなら配列に追加
                    if !isWall(direction: "左", nowPlace: nextTurn.nowPlace){
                        canGoPlaces.append(nowTurn.nowPlace + 10 - 1)
                    }
                }
            }
        }
        // 現在地の左が壁でないなら
        if !isWall(direction: "左", nowPlace: nowTurn.nowPlace){
            // 現在地の左が敵でないなら配列に追加
            if !isEnemy(direction: "左"){
                canGoPlaces.append(nowTurn.nowPlace - 1)
            }else{// 現在地の左が敵なら
                // 敵の左が壁でないなら配列に追加
                if !isWall(direction: "左", nowPlace: nextTurn.nowPlace){
                    canGoPlaces.append(nowTurn.nowPlace - 2)
                }else{// 敵の左が壁なら
                    // 敵の上が壁でないなら配列に追加
                    if !isWall(direction: "上", nowPlace: nextTurn.nowPlace){
                        canGoPlaces.append(nowTurn.nowPlace - 1 - 10)
                    }
                    // 敵の下が壁でないなら配列に追加
                    if !isWall(direction: "下", nowPlace: nextTurn.nowPlace){
                        canGoPlaces.append(nowTurn.nowPlace - 1  + 10)
                    }
                }
            }
        }
        // 現在地の右が壁でないなら
        if !isWall(direction: "右", nowPlace: nowTurn.nowPlace){
            // 現在地の右が敵でないなら配列に追加
            if !isEnemy(direction: "右"){
                canGoPlaces.append(nowTurn.nowPlace + 1)
            }else{// 現在地の右が敵なら
                // 敵の右が壁でないなら配列に追加
                if !isWall(direction: "右", nowPlace: nextTurn.nowPlace){
                    canGoPlaces.append(nowTurn.nowPlace + 2)
                }else{// 敵の右が壁なら
                    // 敵の上が壁でないなら配列に追加
                    if !isWall(direction: "上", nowPlace: nextTurn.nowPlace){
                        canGoPlaces.append(nowTurn.nowPlace + 1 - 10)
                    }
                    // 敵の下が壁でないなら配列に追加
                    if !isWall(direction: "下", nowPlace: nextTurn.nowPlace){
                        canGoPlaces.append(nowTurn.nowPlace + 1  + 10)
                    }
                }
            }
        }
        return canGoPlaces
    }
    
    
    
    // 引数の方向のマスに相手がおるか "上","下","左","右" おる場合はtrue, おらん場合はfalse
    func isEnemy(direction: String) -> Bool{
        var comparePlace = Int()
        switch direction{
        case "上":
            comparePlace = nowTurn.nowPlace - 10
            break
        case "下":
            comparePlace = nowTurn.nowPlace + 10
            break
        case "左":
            comparePlace = nowTurn.nowPlace - 1
            break
        case "右":
            comparePlace = nowTurn.nowPlace + 1
            break
        default:
            break
        }
        if comparePlace == nextTurn.nowPlace{
            return true
        }
        return false
    }
    
    // 引数の方向のマスに壁があるか ある場合はtrue, ない場合はfalse
    func isWall(direction: String, nowPlace: Int) -> Bool{
        switch direction{
        case "上":
            // nowPlace-1番目または+0番目のどちらかのdropWallVorHの要素がHならtrue
            if dropWallVorH[nowPlace - 1] == "H" || dropWallVorH[nowPlace] == "H"{
                return true
            }
            break
        case "下":
            // nowPlace+9番目または+10番目のどちらかのdropWallVorHの要素がHならtrue
            if dropWallVorH[nowPlace + 9] == "H" || dropWallVorH[nowPlace + 10] == "H"{
                return true
            }
            break
        case "左":
            // nowPlace-1番目または+9番目のどちらかのdropWallVorHの要素がVならtrue
            if dropWallVorH[nowPlace - 1] == "V" || dropWallVorH[nowPlace + 9] == "V"{
                return true
            }
            break
        case "右":
            // nowPlace+0番目または+10番目のどちらかのdropWallVorHの要素がVならtrue
            if dropWallVorH[nowPlace] == "V" || dropWallVorH[nowPlace + 10] == "V"{
                return true
            }
            break
        default:
            break
        }
        return false
    }
    
    
    
    // 現在地以外のマスの画像を消して、現在地の画像を設定する
    func setImageNowPlace(){
        print("setImageStart")
        for button in buttons{
            if isNowPlace(button: button, nowPlace: p1.nowPlace){
                print("p1")
                // もし今がp2のターンならbackgroundColorをpurpleに
                if nowTurn.nowPlace == p2.nowPlace{
                    print("1")
                    button.backgroundColor = .purple
                }
                button.setImage(UIImage(named: "p1"), for: .normal)
                button.tintColor = .purple
            }else if isNowPlace(button: button, nowPlace: p2.nowPlace){
                print("p2")
                // もし今がp1のターンならbackgroundColorをorangeに
                if nowTurn.nowPlace == p1.nowPlace{
                    print("2")
                    button.backgroundColor = .orange
                }
                button.setImage(UIImage(named: "p2"), for: .normal)
                button.tintColor = .orange
            }else{
                button.setImage(nil, for: .normal)
                button.backgroundColor = .green
            }
        }
        print("setImageFinish")
    }
    
    
    
    // ゴールしたかどうか, trueならゴール
    func isGoal() -> Bool{
        if nowTurn.nowPlace == p1.nowPlace{
            if 1 <= p1.nowPlace && p1.nowPlace <= 9{
                return true
            }
        }else{
            if 81 <= p2.nowPlace && p2.nowPlace <= 89{
                return true
            }
        }
        return false
    }
    
    
    
    // ゴールした時全面にボタンを表示,タッチしたらタイトルに戻る
    func showWinner(){
        myRoomDB.removeAllObservers()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        if nowTurn.nowPlace == iAm.nowPlace{
            button.setImage(UIImage(named: "youWin"), for: .normal)
        }else{
            button.setImage(UIImage(named: "youLose"), for: .normal)
            myRoomDB.removeValue()
        }
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(backTitle(_:)), for: .touchUpInside)
        view.addSubview(button)
    }
    @objc func backTitle(_ sender: UIButton){
        presentInterstitial()
    }
    
    
    
    // 引数で渡したボタンが現在地のボタンならtrue,そうでないならfalseを返す
    func isNowPlace(button: UIButton, nowPlace: Int) -> Bool{
        if button.tag == nowPlace{
            return true
        }else{
            return false
        }
    }
    
    
    
    // ターン交代
    func changeTurn(){
        let swapTurn = nowTurn
        nowTurn = nextTurn
        nextTurn = swapTurn
    }
    
    
    
    
    
    // ドラッグ開始
        func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if nowTurn.wallCount != 0{
            if nowTurn.nowPlace == iAm.nowPlace{
                // ドラッグされた位置を取得
                let hPoint = session.location(in: nowTurn.hWallView)
                let vPoint = session.location(in: nowTurn.vWallView)
                
                if let hView = nowTurn.hWallView.hitTest(hPoint, with: nil){
                    let dragItem = UIDragItem(itemProvider: NSItemProvider())
                    dragItem.localObject = hView
                    vOrH = "H"
                    return [dragItem]
                }
                if let vView = nowTurn.vWallView.hitTest(vPoint, with: nil){
                    let dragItem = UIDragItem(itemProvider: NSItemProvider())
                    dragItem.localObject = vView
                    vOrH = "V"
                    return [dragItem]
                }
            }
        }
        return []
    }
        
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) ->UITargetedDragPreview? {
        // ドラッグ時のプレビューをビュー全体から壁のみにする
        guard  let wallView = item.localObject as? UIView else {
            return nil
        }
        return UITargetedDragPreview(view: wallView)
    }
        
    
    
    // ドロップした時
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let wallView = UIView()
            
        var wallX = CGFloat()
        var wallY = CGFloat()
        var wallWidth = CGFloat()
        var wallHeight = CGFloat()
            
        for dropView in views{
            if dropView.tag == dropViewTag{
                dropViewX = dropView.frame.origin.x
                dropViewY = dropView.frame.origin.y
            }
        }
        dropWallVorH[dropViewTag] = vOrH
        
        if vOrH == "V"{
            wallX = dropViewX + 10
            wallY = dropViewY - 20
            wallWidth = 10
            wallHeight = 70
        }else if vOrH == "H"{
            wallX = dropViewX - 20
            wallY = dropViewY + 10
            wallWidth = 70
            wallHeight = 10
        }
        wallView.frame = CGRect(x: wallX, y: wallY, width: wallWidth, height: wallHeight)
        nowTurn.wallCount -= 1
        if nowTurn.nowPlace == p1.nowPlace{
            wallView.backgroundColor = .purple
            p1WallCountLabel.text = String(p1.wallCount)
        }else{
            wallView.backgroundColor = .orange
            p2WallCountLabel.text = String(p2.wallCount)
        }
        view.addSubview(wallView)
        // キャンセルボタンを無効にして非表示
        nowTurn.cancelButton.isEnabled = false
        nowTurn.cancelButton.isHidden = true
        // 相手にターンを回す
        changeTurn()
        surrenderButton.isEnabled = false
        surrenderButton.isHidden = true
        for button in buttons{
            button.backgroundColor = .green
            if isNowPlace(button: button, nowPlace: nowTurn.nowPlace){
                // 現在地のボタンを有効にする
                button.isEnabled = true
            }else{
                // 現在地じゃないボタンを無効にする
                button.isEnabled = false
            }
        }
        // 現在地の画像を更新し、他のマスの画像は消す
        setImageNowPlace()
        myRoomDB.child("dropWallPlaceX").setValue(wallX)
        myRoomDB.child("dropWallPlaceY").setValue(wallY)
        myRoomDB.child("dropWallVorH").setValue(vOrH)
        myRoomDB.child("dropViewTag").setValue(dropViewTag)
        myRoomDB.child("nowTurnAction").setValue("dropWall")
        myRoomDB.child("wasTurnPlayer").setValue(iAmString)
    }
        
    
    
    // ドロップできる場所、できない場所を決める
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // ドロップできる場所では .copy を返して
        // 壁を置く際のx座標y座標を決めるためにドロップされたUIViewのx座標y座標を記録
        // ドロップできない場所では .forbidden を返す
        let points: [CGPoint] = createPointArray(session: session)
            
        for row in 0..<points.count{
            if views[row] == views[row].hitTest(points[row], with: nil){
                return dropWall(dropView: views[row])
            }
        }
        
        return UIDropProposal(operation: .forbidden)
    }
        
    
    
    // ドロップできない場所の判定
    func cantPutWall(wallDropView: UIView) -> Bool{
        if dropWallVorH[wallDropView.tag] != ""{
            return true
        }
        if vOrH == "V" {
            if dropWallVorH[wallDropView.tag - 10] == "V" ||
                dropWallVorH[wallDropView.tag + 10] == "V"{
                return true
            }
        }else if vOrH == "H"{
            if dropWallVorH[wallDropView.tag - 1] == "H" ||
                dropWallVorH[wallDropView.tag + 1] == "H"{
            return true
            }
        }
        return false
    }
    
    
    // ゴールできるか, できるならtrue
    func canGoal() -> Bool{
        let storeWallVorH = dropWallVorH[dropViewTag]
        dropWallVorH[dropViewTag] = vOrH
        var baseArrayNowPlayer = canGoArrayWithoutEnemy(nowPlace: nowTurn.nowPlace)
        var baseArrayNextPlayer = canGoArrayWithoutEnemy(nowPlace: nextTurn.nowPlace)
        var i = 0
        var j = 0
        while i < baseArrayNowPlayer.count{
            let place = baseArrayNowPlayer[i]
            let appendArray = canGoArrayWithoutEnemy(nowPlace: place)
            for appendNumber in appendArray{
                var judge = true
                for baseNumber in baseArrayNowPlayer{
                    if baseNumber == appendNumber{
                        judge = false
                    }
                }
                if judge{
                    baseArrayNowPlayer.append(appendNumber)
                }
            }
            i += 1
        }
        while j < baseArrayNextPlayer.count{
            let place = baseArrayNextPlayer[j]
            let appendArray = canGoArrayWithoutEnemy(nowPlace: place)
            for appendNumber in appendArray{
                var judge = true
                for baseNumber in baseArrayNextPlayer{
                    if baseNumber == appendNumber{
                        judge = false
                    }
                }
                if judge{
                    baseArrayNextPlayer.append(appendNumber)
                }
            }
            j += 1
        }
        dropWallVorH[dropViewTag] = storeWallVorH
        
        var nowStart = Int()
        var nowStop = Int()
        var nextStart = Int()
        var nextStop = Int()
        if nowTurn.nowPlace == p1.nowPlace{
            nowStart = 1
            nowStop = 9
            nextStart = 81
            nextStop = 89
        }else{
            nowStart = 81
            nowStop = 89
            nextStart = 1
            nextStop = 9
        }
        var canGoalNow = false
        var canGoalNext = false
        for place in nowStart...nowStop{
            if baseArrayNowPlayer.contains(place){
                canGoalNow = true
            }
        }
        for place in nextStart...nextStop{
            if baseArrayNextPlayer.contains(place){
                canGoalNext = true
            }
        }
        if canGoalNow && canGoalNext{
            return true
        }
        return false
    }
    
    func canGoArrayWithoutEnemy(nowPlace: Int) -> [Int]{
        // 移動できるマスの配列
        var canGoPlaces = [Int]()
        // 上が壁でないなら
        if !isWall(direction: "上", nowPlace: nowPlace){
            canGoPlaces.append(nowPlace - 10)
        }
        // 下が壁でないなら
        if !isWall(direction: "下", nowPlace: nowPlace){
            canGoPlaces.append(nowPlace + 10)
        }
        // 左が壁でないなら
        if !isWall(direction: "左", nowPlace: nowPlace){
            canGoPlaces.append(nowPlace - 1)
        }
        // 右が壁でないなら
        if !isWall(direction: "右", nowPlace: nowPlace){
            canGoPlaces.append(nowPlace + 1)
        }
        return canGoPlaces
    }
        
    
    
    // ドロップできる場所では .copy を返して
    // 壁を置く際のx座標y座標を決めるためにドロップされたUIViewのx座標y座標を記録
    // ドロップできない場所では .forbidden を返す
    func dropWall(dropView: UIView) -> UIDropProposal{
        dropViewTag = dropView.tag
        if cantPutWall(wallDropView: dropView){
            return UIDropProposal(operation: .forbidden)
        }
        if !canGoal(){
            return UIDropProposal(operation: .forbidden)
        }
        return UIDropProposal(operation: .copy)
    }
    
    
    
    // インタースティシャル広告の表示
    func presentInterstitial(){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }else{
            print("まだ広告の準備ができていません")
            dismiss(animated: true, completion: nil)
        }
    }
    // インタースティシャル広告の準備
    func createAndLoadInterstitial() -> GADInterstitial{
        // テスト用ID
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        // 本番用ID
//        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1391275810267480/2776440371")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
    }
    // インタースティシャル広告が閉じられた時
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        dismiss(animated: true, completion: nil)
    }
        
        
        
    // 移動するかどうかをキャンセルする
    @IBAction func p1Cancel(_ sender: Any) {
        // 現在地のボタンを有効にして他のボタンを緑色に戻し無効にする
        for button in buttons{
            if isNowPlace(button: button, nowPlace: p1.nowPlace){
                button.isEnabled = true
            }else{
                button.backgroundColor = .green
                button.isEnabled = false
            }
        }
        // キャンセルボタンを無効にして非表示にする
        p1.cancelButton.isEnabled = false
        p1.cancelButton.isHidden = true
        setImageNowPlace()
    }
    
    // 移動するかどうかをキャンセルする
    @IBAction func p2Cancel(_ sender: Any) {
        // 現在地のボタンを有効にして他のボタンを緑色に戻し無効にする
        for button in buttons{
            if isNowPlace(button: button, nowPlace: p2.nowPlace){
                button.isEnabled = true
            }else{
                button.backgroundColor = .green
                button.isEnabled = false
            }
        }
        // キャンセルボタンを無効にして非表示にする
        p2.cancelButton.isEnabled = false
        p2.cancelButton.isHidden = true
        setImageNowPlace()
    }
    
    
    // アラートを表示して進行状況はを破棄していいならタイトルへ戻る
    @IBAction func surrender(_ sender: Any) {
        let alert = UIAlertController(title: "降参しますか?", message: "あなたの負けになります", preferredStyle: .alert)
        let ok = UIAlertAction(title: "降参する", style: .default) { (alert) in
            self.myRoomDB.removeAllObservers()
            self.myRoomDB.child("nowTurnAction").setValue("surrender")
            self.myRoomDB.child("wasTurnPlayer").setValue(self.iAmString)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            button.setImage(UIImage(named: "youLose"), for: .normal)
            button.contentMode = .scaleToFill
            button.addTarget(self, action: #selector(self.backTitle(_:)), for: .touchUpInside)
            self.view.addSubview(button)
        }
        let cancel = UIAlertAction(title: "やめとく", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    //---------------------------------------------------------------
    
    // ドロップする場所のViewの配列を返す
    func createPointArray(session: UIDropSession) -> [CGPoint]{
        var points = [CGPoint]()
        
        let a1Point = session.location(in: a1View)
        let b1Point = session.location(in: b1View)
        let c1Point = session.location(in: c1View)
        let d1Point = session.location(in: d1View)
        let e1Point = session.location(in: e1View)
        let f1Point = session.location(in: f1View)
        let g1Point = session.location(in: g1View)
        let h1Point = session.location(in: h1View)
        let a2Point = session.location(in: a2View)
        let b2Point = session.location(in: b2View)
        let c2Point = session.location(in: c2View)
        let d2Point = session.location(in: d2View)
        let e2Point = session.location(in: e2View)
        let f2Point = session.location(in: f2View)
        let g2Point = session.location(in: g2View)
        let h2Point = session.location(in: h2View)
        let a3Point = session.location(in: a3View)
        let b3Point = session.location(in: b3View)
        let c3Point = session.location(in: c3View)
        let d3Point = session.location(in: d3View)
        let e3Point = session.location(in: e3View)
        let f3Point = session.location(in: f3View)
        let g3Point = session.location(in: g3View)
        let h3Point = session.location(in: h3View)
        let a4Point = session.location(in: a4View)
        let b4Point = session.location(in: b4View)
        let c4Point = session.location(in: c4View)
        let d4Point = session.location(in: d4View)
        let e4Point = session.location(in: e4View)
        let f4Point = session.location(in: f4View)
        let g4Point = session.location(in: g4View)
        let h4Point = session.location(in: h4View)
        let a5Point = session.location(in: a5View)
        let b5Point = session.location(in: b5View)
        let c5Point = session.location(in: c5View)
        let d5Point = session.location(in: d5View)
        let e5Point = session.location(in: e5View)
        let f5Point = session.location(in: f5View)
        let g5Point = session.location(in: g5View)
        let h5Point = session.location(in: h5View)
        let a6Point = session.location(in: a6View)
        let b6Point = session.location(in: b6View)
        let c6Point = session.location(in: c6View)
        let d6Point = session.location(in: d6View)
        let e6Point = session.location(in: e6View)
        let f6Point = session.location(in: f6View)
        let g6Point = session.location(in: g6View)
        let h6Point = session.location(in: h6View)
        let a7Point = session.location(in: a7View)
        let b7Point = session.location(in: b7View)
        let c7Point = session.location(in: c7View)
        let d7Point = session.location(in: d7View)
        let e7Point = session.location(in: e7View)
        let f7Point = session.location(in: f7View)
        let g7Point = session.location(in: g7View)
        let h7Point = session.location(in: h7View)
        let a8Point = session.location(in: a8View)
        let b8Point = session.location(in: b8View)
        let c8Point = session.location(in: c8View)
        let d8Point = session.location(in: d8View)
        let e8Point = session.location(in: e8View)
        let f8Point = session.location(in: f8View)
        let g8Point = session.location(in: g8View)
        let h8Point = session.location(in: h8View)
        points.append(a1Point)
        points.append(b1Point)
        points.append(c1Point)
        points.append(d1Point)
        points.append(e1Point)
        points.append(f1Point)
        points.append(g1Point)
        points.append(h1Point)
        points.append(a2Point)
        points.append(b2Point)
        points.append(c2Point)
        points.append(d2Point)
        points.append(e2Point)
        points.append(f2Point)
        points.append(g2Point)
        points.append(h2Point)
        points.append(a3Point)
        points.append(b3Point)
        points.append(c3Point)
        points.append(d3Point)
        points.append(e3Point)
        points.append(f3Point)
        points.append(g3Point)
        points.append(h3Point)
        points.append(a4Point)
        points.append(b4Point)
        points.append(c4Point)
        points.append(d4Point)
        points.append(e4Point)
        points.append(f4Point)
        points.append(g4Point)
        points.append(h4Point)
        points.append(a5Point)
        points.append(b5Point)
        points.append(c5Point)
        points.append(d5Point)
        points.append(e5Point)
        points.append(f5Point)
        points.append(g5Point)
        points.append(h5Point)
        points.append(a6Point)
        points.append(b6Point)
        points.append(c6Point)
        points.append(d6Point)
        points.append(e6Point)
        points.append(f6Point)
        points.append(g6Point)
        points.append(h6Point)
        points.append(a7Point)
        points.append(b7Point)
        points.append(c7Point)
        points.append(d7Point)
        points.append(e7Point)
        points.append(f7Point)
        points.append(g7Point)
        points.append(h7Point)
        points.append(a8Point)
        points.append(b8Point)
        points.append(c8Point)
        points.append(d8Point)
        points.append(e8Point)
        points.append(f8Point)
        points.append(g8Point)
        points.append(h8Point)
        
        return points
    }
    
    // 各ボタンのアクション
    func eachButtonAction(button: UIButton){
        if iAm.nowPlace == nowTurn.nowPlace{
            highlightCell(button: button)
        }
    }
    @IBAction func a1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)    }
    @IBAction func d1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)    }
    @IBAction func e1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)    }
    @IBAction func f1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)    }
    @IBAction func g1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)    }
    @IBAction func h1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i1Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i2Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i3Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i4Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i5Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i6Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i7Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i8Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func a9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func b9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func c9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func d9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func e9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func f9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func g9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func h9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    @IBAction func i9Action(_ sender: Any) {
        eachButtonAction(button: sender as! UIButton)
    }
    
    
    // 各ボタン、ビューを配列に格納
    func storeButtonAndViewInArray(){
        buttons.append(a1Button)
        buttons.append(b1Button)
        buttons.append(c1Button)
        buttons.append(d1Button)
        buttons.append(e1Button)
        buttons.append(f1Button)
        buttons.append(g1Button)
        buttons.append(h1Button)
        buttons.append(i1Button)
        buttons.append(a2Button)
        buttons.append(b2Button)
        buttons.append(c2Button)
        buttons.append(d2Button)
        buttons.append(e2Button)
        buttons.append(f2Button)
        buttons.append(g2Button)
        buttons.append(h2Button)
        buttons.append(i2Button)
        buttons.append(a3Button)
        buttons.append(b3Button)
        buttons.append(c3Button)
        buttons.append(d3Button)
        buttons.append(e3Button)
        buttons.append(f3Button)
        buttons.append(g3Button)
        buttons.append(h3Button)
        buttons.append(i3Button)
        buttons.append(a4Button)
        buttons.append(b4Button)
        buttons.append(c4Button)
        buttons.append(d4Button)
        buttons.append(e4Button)
        buttons.append(f4Button)
        buttons.append(g4Button)
        buttons.append(h4Button)
        buttons.append(i4Button)
        buttons.append(a5Button)
        buttons.append(b5Button)
        buttons.append(c5Button)
        buttons.append(d5Button)
        buttons.append(e5Button)
        buttons.append(f5Button)
        buttons.append(g5Button)
        buttons.append(h5Button)
        buttons.append(i5Button)
        buttons.append(a6Button)
        buttons.append(b6Button)
        buttons.append(c6Button)
        buttons.append(d6Button)
        buttons.append(e6Button)
        buttons.append(f6Button)
        buttons.append(g6Button)
        buttons.append(h6Button)
        buttons.append(i6Button)
        buttons.append(a7Button)
        buttons.append(b7Button)
        buttons.append(c7Button)
        buttons.append(d7Button)
        buttons.append(e7Button)
        buttons.append(f7Button)
        buttons.append(g7Button)
        buttons.append(h7Button)
        buttons.append(i7Button)
        buttons.append(a8Button)
        buttons.append(b8Button)
        buttons.append(c8Button)
        buttons.append(d8Button)
        buttons.append(e8Button)
        buttons.append(f8Button)
        buttons.append(g8Button)
        buttons.append(h8Button)
        buttons.append(i8Button)
        buttons.append(a9Button)
        buttons.append(b9Button)
        buttons.append(c9Button)
        buttons.append(d9Button)
        buttons.append(e9Button)
        buttons.append(f9Button)
        buttons.append(g9Button)
        buttons.append(h9Button)
        buttons.append(i9Button)
        views.append(a1View)
        views.append(b1View)
        views.append(c1View)
        views.append(d1View)
        views.append(e1View)
        views.append(f1View)
        views.append(g1View)
        views.append(h1View)
        views.append(a2View)
        views.append(b2View)
        views.append(c2View)
        views.append(d2View)
        views.append(e2View)
        views.append(f2View)
        views.append(g2View)
        views.append(h2View)
        views.append(a3View)
        views.append(b3View)
        views.append(c3View)
        views.append(d3View)
        views.append(e3View)
        views.append(f3View)
        views.append(g3View)
        views.append(h3View)
        views.append(a4View)
        views.append(b4View)
        views.append(c4View)
        views.append(d4View)
        views.append(e4View)
        views.append(f4View)
        views.append(g4View)
        views.append(h4View)
        views.append(a5View)
        views.append(b5View)
        views.append(c5View)
        views.append(d5View)
        views.append(e5View)
        views.append(f5View)
        views.append(g5View)
        views.append(h5View)
        views.append(a6View)
        views.append(b6View)
        views.append(c6View)
        views.append(d6View)
        views.append(e6View)
        views.append(f6View)
        views.append(g6View)
        views.append(h6View)
        views.append(a7View)
        views.append(b7View)
        views.append(c7View)
        views.append(d7View)
        views.append(e7View)
        views.append(f7View)
        views.append(g7View)
        views.append(h7View)
        views.append(a8View)
        views.append(b8View)
        views.append(c8View)
        views.append(d8View)
        views.append(e8View)
        views.append(f8View)
        views.append(g8View)
        views.append(h8View)
    }
}
