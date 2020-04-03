//
//  board.swift
//  QuoridorOnline
//
//  Created by フジタケンシン on 2020/03/05.
//  Copyright © 2020 Kenshin Fujita. All rights reserved.
//

import Foundation

class Board{
    private var vertical = Int()
    private var horizontal = Int()
    
    init(vertical: Int, horizontal: Int) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
    
    // vertical ✖︎ horizontal の盤面を作成してその盤面の周りに壁を配置した配列を返す
    /*
      例)vertical:2, horizontal:4
      ---
     |   |
      ---
     return [ "","H","H","H", ""
             "V", "", "", "","V"
              "","H","H","H", ""]
     */
    func createBoard() -> [String]{
        var baseBoard = [String]()
        for i in 0...vertical{
            for j in 0...horizontal{
                if i == 0 || i == vertical{
                    if j != 0 && j != horizontal{
                        baseBoard.append("H")
                    }else{
                        baseBoard.append("")
                    }
                }else{
                    if j == 0 || j == horizontal{
                        baseBoard.append("V")
                    }else{
                        baseBoard.append("")
                    }
                }
            }
        }
        return baseBoard
    }
}
