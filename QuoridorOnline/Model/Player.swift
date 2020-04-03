//
//  Player.swift
//  QuoridorOnline
//
//  Created by フジタケンシン on 2020/03/05.
//  Copyright © 2020 Kenshin Fujita. All rights reserved.
//

import Foundation
import UIKit

class Player{
    /* 自分の現在地 ボタンのタグと対応 (隣の判定のために10nはとばす)
     1  2  3  4  5  6  7  8  9
    11 12 13 14 ...
    ...
    81 82 83 84 85 86 87 88 89
    */
    var nowPlace: Int
    
    // 残りの壁の所持数
    var wallCount: Int
    
    // 移動をやめるキャンセルボタン
    var cancelButton: UIButton
    
    // ドラッグアンドドロップで置く壁のビュー
    // 垂直方向がV(vertical), 水平方向がH(Horizontal)
    var vWallView: UIView
    var hWallView: UIView
    
    init(nowPlace: Int, wallCount: Int, cancelButton: UIButton, vWallView: UIView, hWallView: UIView) {
        self.nowPlace = nowPlace
        self.wallCount = wallCount
        self.cancelButton = cancelButton
        self.vWallView = vWallView
        self.hWallView = hWallView
    }
}
