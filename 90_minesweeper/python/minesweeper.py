# coding: utf-8
import random
import os

class Cell:
    __isMine = False
    __isOpen = False
    def __init__(self,isMine):
        self.__isMine = isMine

    def open(self):
        self.__isOpen = True

    def isOpen(self):
        return self.__isOpen

    def isMine(self):
        return self.__isMine

class Field:
    __cells = []
    __x = 0
    __y = 0
    __mine = 0

    def __init__(self,x,y,mine):
        self.__x = x
        self.__y = y
        self.__mine = mine
        for i in range(x*y):
            cellMine = False
            if i < mine:
                cellMine = True
            self.__cells.append(Cell(cellMine))
        random.shuffle(self.__cells)

    # 標準出力にテキストで表示する。左と上にヘッダとして座標用の数を表示する。開いてない="/" 開いた=1～8 or " "(スペース)
    def printField(self):
        header1 = " |"
        header2 = "--"
        for ix in range(self.__x):
            header1 += str(ix % 10)
            header2 += "-"
        print(header1)
        print(header2)
        for iy in range(self.__y):
            line = str(iy % 10)
            line += "|"
            for ix in range(self.__x):
                item = self.__cells[iy * self.__x + ix]
                if True == item.isOpen():
                    if True == item.isMine():
                        line += "*"
                    elif self.__roundNum(ix,iy) ==0:
                        line += " "
                    else:
                        line += str(self.__roundNum(ix,iy))
                else:
                    line += "/"
            print(line)

    def open(self,x,y):
        if x < 0:
            return
        elif x >= self.__x:
            return
        elif y < 0:
            return
        elif y >= self.__y:
            return
        else:
            item = self.__cells[y * self.__x + x]
            if item.isOpen():
                return
            item.open()
            if item.isMine() == False:
                if self.__roundNum(x,y) == 0: #0なら隣接cellをOpenする
                    self.open(x-1,y-1) #左上
                    self.open(x  ,y-1) #中上
                    self.open(x+1,y-1) #右上
                    self.open(x-1,y  ) #左中
                    self.open(x+1,y  ) #右中
                    self.open(x-1,y+1) #左下
                    self.open(x  ,y+1) #中下
                    self.open(x+1,y+1) #右下

    def __roundNum(self,x,y):
        round = 0
        if self.__isMine(x-1,y-1): #左上
            round += 1
        if self.__isMine(x  ,y-1): #中上
            round += 1
        if self.__isMine(x+1,y-1): #右上
            round += 1
        if self.__isMine(x-1,y  ): #左中
            round += 1
        if self.__isMine(x+1,y  ): #右中
            round += 1
        if self.__isMine(x-1,y+1): #左下
            round += 1
        if self.__isMine(x  ,y+1): #中下
            round += 1
        if self.__isMine(x+1,y+1): #右下
            round += 1
        return round

    #指定セルが存在してmine状態の場合にTrueを返す
    def __isMine(self,x,y):
        if x < 0:
            return False
        elif x >= self.__x:
            return False
        elif y < 0:
            return False
        elif y >= self.__y:
            return False
        return self.__cells[y * self.__x + x].isMine()

    def isOver(self):
      overFlag = False
      for i in range(self.__x * self.__y):
          item = self.__cells[i]
          if item.isOpen() and item.isMine():
              overFlag = True
              break
      return overFlag

    def isClear(self):
      closeCount = 0
      overFlag = False
      for i in range(self.__x * self.__y):
          item = self.__cells[i]
          if item.isOpen() == False:
              closeCount += 1
      if closeCount == self.__mine:
          overFlag = True
      return overFlag

def cleanScreen():
    os.system('cls') # windows
#    os.system('clear') # linux

def main():
    fieldWidth = 20
    fieldHeight = 8
    fieldMine = 30

    field = Field(fieldWidth,fieldHeight,fieldMine)
    while field.isOver() == False and field.isClear() == False:
        cleanScreen()
        field.printField()
        print( "input:x y" )
        ix, iy = map(int, input().split())
        field.open(ix,iy)

    cleanScreen()
    field.printField()

    if field.isOver():
        print( "==over==" )
    if field.isClear():
        print( "==clear==" )

if __name__ == "__main__":
    main()

