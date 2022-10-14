#"boom.h"
#"lines.h"
#"monsters.h"
#"spawns.h"
#"standard.h"

rowCount {9}
colCount {9}
ceilingHeight { add(mul(rowCount,128),300) }
-- scrollSpeed { 45 }
scrollSpeed { 34 }
barrel { setthing(2035) }
burningbarrel { setthing(70) }
browntree { setthing(54) }
raisefloor { 24617 }
lowerfloor { 24809 }

main {
  turnaround
  undefx
  mid("GRAY1")
  !origin
  movestep(mul(128,rowCount),0)
  linetype(253, $scroll_north) straight(scrollSpeed)
  linetype(0,0) right(1)
  right(scrollSpeed)
  right(1)
  sectortype(0,$scroll_north)
  rightsector(0,ceilingHeight,161)
  rotright
  set("scrollingSector",lastsector)
  movestep(0,1)
  
  initializeTags
  sectortype(0,0)
  !controlSectors
  box(25,ceilingHeight,161,1,mul(colCount,20))
  set("raisedSector",lastsector)
  movestep(1,0)
  sectortype(0,barrelStartBlockerTag)
  box(25,ceilingHeight,161,1,1)
  set("barrelStartBlockerSector",lastsector)
  movestep(0,1)
  forvar("y",0,sub(rowCount,1),
    !row
    forvar("x",0,sub(colCount,1),
      sectortype(0,cellDeadBlockerTag(x,y))
      box(25,ceilingHeight,161,1,1)
      set(cat3("cellDeadBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellAliveBlockerTag(x,y))
      box(25,ceilingHeight,161,1,1)
      set(cat3("cellAliveBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellKilledBlockerTag(x,y))
      box(0,ceilingHeight,161,1,1)
      set(cat3("cellKilledBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellRevivedBlockerTag(x,y))
      box(25,ceilingHeight,161,1,1)
      set(cat3("cellRevivedBlockerSector",x,y),lastsector)
      movestep(0,1)
      forvar("nbrIx",0,7,
        sectortype(0,cellFinishedTag(x,y,get("nbrIx")))
        box(25,ceilingHeight,161,1,1)
        set(cat4("cellFinishedSector",x,y,get("nbrIx")),lastsector)
        movestep(0,1)
        sectortype(0,cellStartedTag(x,y,get("nbrIx")))
        box(25,ceilingHeight,161,1,1)
        set(cat4("cellStartedSector",x,y,get("nbrIx")),lastsector)
        movestep(0,1)
      )
    )
    ^row
    movestep(1,0)

    forcesector(get("raisedSector"))
    box(0,0,0,1,mul(colCount,20))
    movestep(1,0)
  )
  ^controlSectors

  ^origin

  forcesector(get("scrollingSector"))
  stdbox(mul(128,rowCount),mul(288,colCount))
  !checkers
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !checker
      checkerForCell(get("x"),get("y"))
      ^checker
      movestep(128,0)
    )      
    ^column
    movestep(0,128)
  )
  ^checkers
  movestep(0,mul(128,colCount))
  !aliveCells
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      aliveCellBlock(get("x"),get("y"))
    )
    ^column
    movestep(0,128)
  )
  ^aliveCells  
  movestep(0,mul(128,colCount))
  !ladders
  forcesector(get("scrollingSector"))
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      checkLadderForCell(get("x"),get("y"))
    )
    ^column
    movestep(0, 32)
  )
  ^ladders
  movestep(0,mul(32,colCount))
  !killCells
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
          killCellBlock(x,y)
    )
    ^column
    movestep(0,32)
  )
  ^killCells
  movestep(mul(64,rowCount),0)

  !reviveCells
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      reviveCellBlock(x,y)
    )
    ^column
    movestep(0,32)
  )
  ^reviveCells
  movestep(mul(-64,rowCount),mul(32,colCount))

  !keepCells
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      keepCellBlock(x,y)
    )
    ^column
    movestep(0,32)
  )
  ^keepCells
  movestep(mul(64,rowCount),0)

  !waitNbrsStarted
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      waitAllNbrsStartedBlock(x,y)
    )
    ^column
    movestep(0,32)
  )
  ^waitNbrsStarted
  movestep(mul(64,rowCount),0)

  !barrels
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      barrelStart(get("x"),get("y"))
    )
    ^column
    movestep(0,32)
  )
  ^barrels
  movestep(mul(-128,rowCount),mul(32,colCount))
  
  sectortype(0, $mainArea)
  stdbox(add(mul(rowCount,192),1000),add(mul(colCount,192),1000))
  !playbox
  movestep(256, 64)

  player1start
  thingangle(rotatedAngle(angle_west))

  movestep(-224, 0)

  movestep(32,0)
  linetype(lowerfloor,barrelStartBlockerTag)
  ibox(8,ceilingHeight,161,8,32)
  linetype(0,0)
  popsector

  movestep(0, 64)
  bot("COMPSTA1")
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      linetype(lowerfloor,cellDeadBlockerTag(x,y))
      ibox(16,ceilingHeight,161,128,128)
      popsector
      movestep(192,0)
    )
    ^column
    movestep(0,192)
  )
  ^playbox
  movestep(0,add(mul(colCount,192),1000))
  !c
  forvar("x",0,sub(colCount,1),
    bot("MARBFAC3")
    box(0,ceilingHeight,200,128,4)
    movestep(128,0)
  )
  ^c
  movestep(0,4)
  forvar("y",0,sub(rowCount,1),
    !column
    forvar("x",0,sub(colCount,1),
      bot("BIGDOOR7")
      sectortype(0,marbTag(y,x))
      box(mul(y,128),ceilingHeight,200,128,4)
      movestep(0,4)
      bot("MARBFAC3")
      box(mul(add(y,1),128),ceilingHeight,200,128,4)
      movestep(128,-4)
    )
    ^column
    movestep(0,8)
  )
}

checkLadderStep(x, y, nbrIx, nbrCnt) {
  if(lessthaneq(1,nbrCnt),
    if(lessthan(nbrIx,1),die("checkLadderStep(x,y,0,c"))
    if(lessthan(nbrCnt,1),die("checkLadderStep(x,y,i,0"))
    movestep(1,0)
    fliplinesector(20,0,checkeeOkLineTag(x,y,sub(nbrIx,1),sub(nbrCnt,1)),get("scrollingSector"))
  )
  movestep(1,0)
  linesector(20,244,checkeeLineTag(x,y,nbrIx,nbrCnt),get("scrollingSector"))
}

checkLadderForCell(x, y) {
  !box
  movestep(10,6)
  fliplinesector(20,0,startCheckTag(x,y),get("scrollingSector"))
  forvar("nbrIx",0,7,
    movestep(1,0)
    linesector(20,raisefloor,cellNbrStartedTag(x,y,get("nbrIx")),get("scrollingSector"))
  )
  fori(0, 6,
    checkLadderStep(x, y, i, 0)
  )
  movestep(1,0)
  linesector(20,208,killCellTag(x,y),get("scrollingSector"))

  fori(1,7,
    checkLadderStep(x, y, i, 1)
  )
  movestep(1,0)
  linesector(20,208,killCellTag(x,y),get("scrollingSector"))

  fori(2,7,
    checkLadderStep(x, y, i, 2)
  )
  movestep(1,0)
  linesector(20,208,keepCellTag(x,y),get("scrollingSector"))

  fori(3,7,
    checkLadderStep(x, y, i, 3)
  )
  movestep(1,0)
  linesector(20,208,reviveCellTag(x,y),get("scrollingSector"))
  ^box
  movestep(128,0)
}

checkerForCell(x, y) {
  movestep(0,14)
  set("neighbIx",0)
  !neighbs
  forvar("col",0,1,
    !neighbourColumn
    forvar("row",0,3,
      movestep(10,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),0),get("scrollingSector"))
      movestep(1,0)
      ifelse(eq(get("neighbIx"),7),
        linesector(2,208,get(cat2("killCell",invNeighbourString(x,y,get("neighbIx")))),get("scrollingSector")),
        linesector(2,244,checkerOkLineTag(x,y,get("neighbIx"),0),get("scrollingSector"))
      )
      movestep(1,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),1),get("scrollingSector"))
      movestep(1,0)
      ifelse(eq(get("neighbIx"),7),
        linesector(2,208,get(cat2("keepCell",invNeighbourString(x,y,get("neighbIx")))),get("scrollingSector")),
        linesector(2,244,checkerOkLineTag(x,y,get("neighbIx"),1),get("scrollingSector"))
      )
      movestep(1,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),2),get("scrollingSector"))
      movestep(1,0)
      ifelse(eq(get("neighbIx"),7),
        linesector(2,208,get(cat2("reviveCell",invNeighbourString(x,y,get("neighbIx")))),get("scrollingSector")),
        linesector(2,244,checkerOkLineTag(x,y,get("neighbIx"),2),get("scrollingSector"))
      )
      movestep(1,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),3),get("scrollingSector"))
      movestep(1,0)
      linesector(2,208,get(cat2("killCell",invNeighbourString(x,y,get("neighbIx")))),get("scrollingSector"))
      movestep(11,0)
      inc("neighbIx",1)
    )
    ^neighbourColumn
    movestep(0,98)
  )
  ^neighbs
  movestep(56,50)
  mancubus
  thingangle(rotatedAngle(angle_west))
  movestep(-4,-10)
  fliplinesector(20,0,cellDeadTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,raisefloor,cellRevivedBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,cellKilledBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,marbTag(x,y),get("scrollingSector"))
  movestep(2,0)
  linesector(20,raisefloor,cellAliveBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,244,cellAliveTag(x,y),get("scrollingSector"))
  movestep(46,0)
  forcesector(cellDeadBlockerSector(x,y))
  ibox(0,0,0,1,20)
  popsector
}

aliveCellBlock(x,y) {
  sectortype(0,0)
  movestep(58,16)
  fliplinesector(96,0,cellAliveTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(96,raisefloor,cellKilledBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(96,lowerfloor,cellRevivedBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(96,raisefloor,marbTag(x,y),get("scrollingSector"))
  movestep(2,0)
  linesector(96,raisefloor,cellDeadBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(96,244,cellDeadTag(x,y),get("scrollingSector"))
  movestep(46,0)
  forcesector(cellAliveBlockerSector(x,y))
  ibox(0,0,0,1,96)
  popsector
  movestep(19,-16)
}

killCellBlock(x, y) {
  !killCellBlock
  sectortype(0,killCellTag(x,y))
  stdboxwithfrontline(11,32,lowerfloor,cellFinishedTag(x,y,0))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)
  forcesector(get("scrollingSector"))
  stdbox(53,32)
  movestep(1,6)
  forvar("nbrIx",1,7,
    linesector(20,lowerfloor,cellFinishedTag(x,y,get("nbrIx")),get("scrollingSector"))
    movestep(1,0)
  )

  movestep(10,2)
  !allFinished
  forvar("nbrIx",0,7,
    forcesector(cellNbrFinishedSector(x,y,get("nbrIx")))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allFinished
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  movestep(-9,-2)
  
  linesector(20,raisefloor,cellDeadBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,cellAliveBlockerTag(x,y),get("scrollingSector"))
  movestep(11,0)
  forcesector(cellKilledBlockerSector(x,y))
  ibox(0,0,0,1,20)
  popsector
  movestep(-9,0)
  linesector(20,208,allNbrsFinishedTag(x,y),get("scrollingSector"))
  ^killCellBlock
  movestep(64,0)
}
reviveCellBlock(x, y) {
  !reviveCellBlock
  sectortype(0,reviveCellTag(x,y))
  stdboxwithfrontline(11,32,lowerfloor,cellFinishedTag(x,y,0))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)
  forcesector(get("scrollingSector"))
  stdbox(53,32)
  movestep(1,6)
  forvar("nbrIx",1,7,
    linesector(20,lowerfloor,cellFinishedTag(x,y,get("nbrIx")),get("scrollingSector"))
    movestep(1,0)
  )

  movestep(10,2)
  !allFinished
  forvar("nbrIx",0,7,
    forcesector(cellNbrFinishedSector(x,y,get("nbrIx")))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allFinished
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  movestep(-9,-2)

  linesector(20,raisefloor,cellAliveBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,cellDeadBlockerTag(x,y),get("scrollingSector"))
  movestep(11,0)
  forcesector(cellRevivedBlockerSector(x,y))
  ibox(0,0,0,1,20)
  popsector
  movestep(-9,0)
  linesector(20,208,allNbrsFinishedTag(x,y),get("scrollingSector"))
  ^reviveCellBlock
  movestep(64,0)
}
keepCellBlock(x, y) {
  !keepCellBlock
  sectortype(0,keepCellTag(x,y))
  stdboxwithfrontline(11,32,lowerfloor,cellFinishedTag(x,y,0))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)
  forcesector(get("scrollingSector"))
  stdbox(53,32)
  movestep(1,6)
  forvar("nbrIx",1,7,
    linesector(20,lowerfloor,cellFinishedTag(x,y,get("nbrIx")),get("scrollingSector"))
    movestep(1,0)
  )

  movestep(10,2)
  !allFinished
  forvar("neighbIx",0,7,
    forcesector(cellNbrFinishedSector(x,y,get("neighbIx")))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allFinished
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  movestep(-9,-2)

  linesector(20,208,allNbrsFinishedTag(x,y),get("scrollingSector"))
  ^keepCellBlock  
  movestep(64,0)
}
waitAllNbrsStartedBlock(x,y) {
  !waitAll
  sectortype(0,allNbrsFinishedTag(x,y))
  stdboxwithfrontline(11,32,raisefloor,cellNbrFinishedTag(x,y,0))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)  
  forcesector(get("scrollingSector"))
  stdbox(53,32)
  movestep(1,6)
  linesector(20,lowerfloor,cellStartedTag(x,y,0),get("scrollingSector"))
  movestep(1,0)
  forvar("nbrIx",1,7,
    linesector(20,raisefloor,cellNbrFinishedTag(x,y,get("nbrIx")),get("scrollingSector"))
    movestep(1,0)
    linesector(20,lowerfloor,cellStartedTag(x,y,get("nbrIx")),get("scrollingSector"))
    movestep(1,0)
  )

  movestep(10,2)
  !allStarted
  forvar("nbrIx",0,7,
    forcesector(cellNbrStartedSector(x,y,get("nbrIx")))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allStarted
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  movestep(-9,-2)

  linesector(20,244,startCheckTag(x,y),get("scrollingSector"))
  ^waitAll
  movestep(64,0)
}

linesector(len,type,tag,sectorIndex) {
  forcesector(sectorIndex)
  linetype(type,tag) step(0,len)
  linetype(0,0) step(0,neg(len))
  rightsector(0,0,0)
}
fliplinesector(len,type,tag,sectorIndex) {
  forcesector(sectorIndex)
  movestep(0,len)
  linetype(type,tag) step(0,neg(len))
  linetype(0,0) step(0,len)
  movestep(0,neg(len))
  rightsector(0,0,0)
}

barrelStart(x,y) {
  !box
  forcesector(get("scrollingSector"))
  stdbox(32,32)
  movestep(10,16)
  barrel
  thing
  movestep(1,-10)
  linesector(20,208,keepCellTag(x,y),get("scrollingSector"))
  movestep(9,0)
  forcesector(get("barrelStartBlockerSector"))
  ibox(0,0,0,1,20)
  popsector
  ^box
  movestep(32,0)
}

neighbourString(x, y, neighbIx) {
  if(or(lessthan(neighbIx,0),lessthan(7,neighbIx)),die(neighbIx))
  ifelse(eq(neighbIx,0),
    cat2(subx1(x),suby1(y)),
    ifelse(eq(neighbIx,1),
      cat2(subx1(x),y),
      ifelse(eq(neighbIx,2),
        cat2(subx1(x),addy1(y)),
	ifelse(eq(neighbIx,3),
          cat2(x,suby1(y)),
	  ifelse(eq(neighbIx,4),
            cat2(x,addy1(y)),
	    ifelse(eq(neighbIx,5),
              cat2(addx1(x),suby1(y)),
	      ifelse(eq(neighbIx,6),
                cat2(addx1(x),y),
		cat2(addx1(x),addy1(y)))))))))
}
invNeighbourString(x, y, neighbIx) {
  neighbourString(x,y,sub(7,neighbIx))
}
subx1(x) {
  ifelse(eq(x,0),sub(colCount,1),sub(x,1))
}
addx1(x) {
  ifelse(lessthan(x,sub(colCount,1)),add(x,1),0)
}
suby1(y) {
  ifelse(eq(y,0),sub(rowCount,1),sub(y,1))
}
addy1(y) {
  ifelse(lessthan(y,sub(rowCount,1)),add(y,1),0)
}

initializeTags {
  set("barrelStartBlocker",newtag)
  forvar("x",0,sub(colCount,1),
    forvar("y",0,sub(rowCount,1),
      set(cat3("killCell",x,y),newtag)
      set(cat3("keepCell",x,y),newtag)
      set(cat3("reviveCell",x,y),newtag)
      set(cat3("cellDead",x,y),newtag)
      set(cat3("cellDeadBlocker",x,y),newtag)
      set(cat3("cellKilledBlocker",x,y),newtag)
      set(cat3("cellAlive",x,y),newtag)
      set(cat3("cellAliveBlocker",x,y),newtag)
      set(cat3("cellRevivedBlocker",x,y),newtag)
      set(cat3("startNextTurn",x,y),newtag)
      set(cat3("startCheck",x,y),newtag)
      set(cat3("allNbrsFinished",x,y),newtag)
      set(cat3("marb",x,y),newtag)
      forvar("nbrIx",0,7,
        set(cat4("cellFinished",x,y,get("nbrIx")),newtag)
        set(cat4("cellStarted",x,y,get("nbrIx")),newtag)
        forvar("neighbCnt",0,3,
          set(cat5("check",get("x"),get("y"),get("nbrIx"),get("neighbCnt")),newtag)
          if(lessthan(get("neighbCnt"),3),
            set(cat5("checkOk",get("x"),get("y"),get("nbrIx"),get("neighbCnt")),newtag))
        )
      )
    )
  )
}
barrelStartBlockerTag {
  get("barrelStartBlocker")
}

checkeeLineTag(x,y,neighbIx,neighbCnt) {
  get(cat4("check",neighbourString(x,y,neighbIx),neighbIx,neighbCnt))
}
checkeeOkLineTag(x,y,neighbIx,neighbCnt) {
  get(cat4("checkOk",neighbourString(x,y,neighbIx),neighbIx,neighbCnt))
}
checkerLineTag(x,y,neighbIx,neighbCnt) {
  get(cat5("check",x,y,neighbIx,neighbCnt))
}
checkerOkLineTag(x,y,neighbIx,neighbCnt) {
  get(cat5("checkOk",x,y,neighbIx,neighbCnt))
}
killCellTag(x,y) {
  get(cat3("killCell",x,y))
}
keepCellTag(x,y) {
  get(cat3("keepCell",x,y))
}
reviveCellTag(x,y) {
  get(cat3("reviveCell",x,y))
}
cellDeadTag(x,y) {
  get(cat3("cellDead",x,y))
}
cellDeadBlockerTag(x,y) {
  get(cat3("cellDeadBlocker",x,y))
}
cellKilledBlockerTag(x,y) {
  get(cat3("cellKilledBlocker",x,y))
}
cellAliveTag(x,y) {
  get(cat3("cellAlive",x,y))
}
cellAliveBlockerTag(x,y) {
  get(cat3("cellAliveBlocker",x,y))
}
cellRevivedBlockerTag(x,y) {
  get(cat3("cellRevivedBlocker",x,y))
}
startNextTurnTag(x,y) {
  get(cat3("startNextTurn",x,y))
}
startCheckTag(x,y) {
  get(cat3("startCheck",x,y))
}
allNbrsFinishedTag(x,y) {
  get(cat3("allNbrsFinished",x,y))
}
cellFinishedTag(x,y,nbrIx) {
  get(cat4("cellFinished",x,y,nbrIx))
}
cellNbrFinishedTag(x,y,nbrIx) {
  get(cat3("cellFinished",neighbourString(x,y,nbrIx),nbrIx))
}
cellStartedTag(x,y,nbrIx) {
  get(cat4("cellStarted",x,y,nbrIx))
}
cellNbrStartedTag(x,y,nbrIx) {
  get(cat3("cellStarted",neighbourString(x,y,nbrIx),nbrIx))
}
cellNbrFinishedSector(x,y,nbrIx) {
  get(cat3("cellFinishedSector",neighbourString(x,y,nbrIx),nbrIx))
}
cellNbrStartedSector(x,y,nbrIx) {
  get(cat3("cellStartedSector",neighbourString(x,y,nbrIx),nbrIx))
}
cellAliveBlockerSector(x,y) {
  get(cat3("cellAliveBlockerSector",x,y))
}
cellRevivedBlockerSector(x,y) {
  get(cat3("cellRevivedBlockerSector",x,y))
}
cellDeadBlockerSector(x,y) {
  get(cat3("cellDeadBlockerSector",x,y))
}
cellKilledBlockerSector(x,y) {
  get(cat3("cellKilledBlockerSector",x,y))
}
marbTag(x,y) {
  get(cat3("marb",x,y))
}
stdbox(x,y) {
  box(0,ceilingHeight,200,x,y)
}
stdboxwithfrontline(x,y,type,tag) {
  linetype(0,0) straight(x)
  linetype(type,tag) right(y)
  linetype(0,0) right(x)
  right(y)
  rightsector(0,ceilingHeight,161)
  rotright
}

flipright(len) {
  rotright up step(len,0) down turnaround step(len,0) up turnaround step(len,0) down
}

cat2(a, b) {
  cat(a, cat(",", b))
}
cat3(a, b, c) {
  cat2(a, cat2(b, c))
}
cat4(a, b, c, d) {
  cat2(a, cat3(b, c, d))
}
cat5(a, b, c, d, e) {
  cat2(a, cat4(b, c, d, e))
}

forvar(var,from,to,body) {
  set(var, from)
  for(from, to,
    body
    inc(var,1)
  )
}
invbox(floor,ceil,light,x,y) {
  right(y)
  left(x)
  left(y)
  left(x)
  turnaround
  rightsector(floor,ceil,light)
}
partialibox(floor,ceil,light,x,y) {
  right(y)
  left(x)
  left(y)
  innerleftsector(floor,ceil,light)
  up
  left(x)
  down
  turnaround
  
}
neg(n) {
  sub(0,n)
}
mod(n,d) {
 sub(n,mul(div(n,d),d))
}
rotatedAngle(angle) {
  ifelse(eq(getorient,0),
    angle,
    ifelse(eq(getorient,1),
      mod(add(angle,270),360),
      ifelse(eq(getorient,2),
        mod(add(angle,180),360),
	mod(add(angle,90),360))))
}
