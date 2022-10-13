#"boom.h"
#"lines.h"
#"monsters.h"
#"spawns.h"
#"standard.h"

rowCount {10}
colCount {10}
-- scrollSpeed { 45 }
scrollSpeed { 30 }
barrel { setthing(2035) }
burningbarrel { setthing(70) }
browntree { setthing(54) }
raisefloor { 24617 }
lowerfloor { 24809 }

main {
  turnaround
  undefx
  !origin
  movestep(mul(128,rowCount),0)
  linetype(253, $scroll_north) straight(scrollSpeed)
  linetype(0,0) right(1)
  right(scrollSpeed)
  right(1)
  sectortype(0,$scroll_north)
  rightsector(0,128,161)
  rotright
  set("scrollingSector",lastsector)
  movestep(0,1)
  
  initializeLineTags  
  sectortype(0,0)
  !controlSectors
  box(25,128,161,1,add(mul(colCount,6),1))
  set("raisedSector",lastsector)
  movestep(1,0)
  sectortype(0,barrelStartBlockerTag)
  box(25,128,161,1,1)
  set("barrelStartBlockerSector",lastsector)
  forvar("y",0,sub(rowCount,1),
    !row
    movestep(0,1)
    forvar("x",0,sub(colCount,1),
      sectortype(0,cellDeadBlockerTag(x,y))
      box(25,128,161,1,1)
      set(cat3("cellDeadBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellAliveBlockerTag(x,y))
      box(25,128,161,1,1)
      set(cat3("cellAliveBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellKilledBlockerTag(x,y))
      box(0,128,161,1,1)
--      box(25,128,161,1,1)
      set(cat3("cellKilledBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellRevivedBlockerTag(x,y))
      box(25,128,161,1,1)
      set(cat3("cellRevivedBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellFinishedTag(x,y))
      box(25,128,161,1,1)
      set(cat3("cellFinishedSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellStartedTag(x,y))
      box(25,128,161,1,1)
      set(cat3("cellStartedSector",x,y),lastsector)
      movestep(0,1)
    )
    ^row
    movestep(1,0)
    forcesector(get("raisedSector"))
    box(25,128,161,1,add(mul(colCount,6),1))
    movestep(1,0)
  )
  ^controlSectors
  movestep(0,add(mul(colCount,6),1))
  
  !barrels
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      barrelStart(get("x"),get("y"))
    )
    ^column
    movestep(0,22)
  )
  ^barrels
  movestep(0,mul(22,colCount))
  !ladders
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      checkLadderForCell(get("x"),get("y"))
    )
    ^column
    movestep(0, 30)
  )
  ^ladders
  movestep(0,mul(30,colCount))
  ^origin
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
  movestep(0,mul(32,colCount))

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
  movestep(0,mul(32,colCount))

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
  movestep(0,mul(32,colCount))
  
--  !waitNbrsFinished
--  forvar("x",0,sub(colCount,1),
--    !column
--    forvar("y",0,sub(rowCount,1),
--      waitAllNbrsFinishedBlock(x,y)
--    )
--    ^column
--    movestep(0,22)
--  )
--  ^waitNbrsFinished
--  movestep(0,mul(22,colCount))
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
  movestep(0,mul(32,colCount))
  
  sectortype(0, $mainArea)
  stdbox(1000, 1000)
  movestep(256, 64)

  player1start
  thingangle(rotatedAngle(angle_west))

  movestep(-224, 0)

  movestep(32,0)
  linetype(lowerfloor,barrelStartBlockerTag)
  ibox(8,128,161,8,32)
  linetype(0,0)

  movestep(0, 64)
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      linetype(lowerfloor,cellDeadBlockerTag(x,y))
      ibox(8,128,161,64,64)
      movestep(add(64,16),0)
    )
    ^column
    movestep(0,add(64,16))
  )
}

checkLadderStep(x, y, neighbIx, neighbCnt) {
  if(lessthaneq(1,neighbCnt),
    if(lessthan(neighbIx,1),die("checkLadderStep(x,y,0,c"))
    if(lessthan(neighbCnt,1),die("checkLadderStep(x,y,i,0"))
    movestep(1,0)
    fliplinesector(20,0,checkeeOkLineTag(x,y,sub(neighbIx,1),sub(neighbCnt,1)),get("scrollingSector"))
  )
  movestep(1,0)
  linesector(20,244,checkeeLineTag(x,y,neighbIx,neighbCnt),get("scrollingSector"))
}

checkLadderForCell(x, y) {
  forcesector(get("scrollingSector"))
  box(0,128,161,78,30)
  movestep(10,5)
  fliplinesector(20,0,startCheckTag(x,y),get("scrollingSector"))
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
  movestep(0, -5)
  --headroom for front of the barrel
  movestep(21,0)
}

checkerForCell(x, y) {
  forcesector(get("scrollingSector"))
  stdbox(128,128)
  movestep(0,14)
  set("neighbIx",0)
  !neighbs
  forvar("col",0,1,
    !neighbourColumn
    forvar("row",0,3,
      movestep(10,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),0),get("scrollingSector"))
      movestep(1,0)
      linesector(2,244,checkerOkLineTag(x,y,get("neighbIx"),0),get("scrollingSector"))
      movestep(1,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),1),get("scrollingSector"))
      movestep(1,0)
      linesector(2,244,checkerOkLineTag(x,y,get("neighbIx"),1),get("scrollingSector"))
      movestep(1,0)
      fliplinesector(2,0,checkerLineTag(x,y,get("neighbIx"),2),get("scrollingSector"))
      movestep(1,0)
      linesector(2,244,checkerOkLineTag(x,y,get("neighbIx"),2),get("scrollingSector"))
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
--      cacodemon
--      demon
--      archvile
  mancubus
  thingangle(rotatedAngle(angle_west))
--      browntree
--      burningbarrel
--      player1start
--      movestep(-3,-1)
  movestep(-3,-10)
  fliplinesector(20,0,cellDeadTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,cellKilledBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,raisefloor,cellRevivedBlockerTag(x,y),get("scrollingSector"))
  movestep(2,0)
  linesector(20,raisefloor,cellAliveBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,244,cellAliveTag(x,y),get("scrollingSector"))
  movestep(46,0)
  forcesector(cellDeadBlockerSector(x,y))
  ibox(25,128,161,1,20)
}

aliveCellBlock(x,y) {
  sectortype(0,0)
  forcesector(get("scrollingSector"))
  stdbox(128,128)
--  stdboxwithfrontline(49,98,raisefloor,cellDeadBlockerTag(x,y))
  movestep(58,16)
  fliplinesector(96,0,cellAliveTag(x,y),get("scrollingSector"))
--  movestep(1, -1)
--  forcesector(get("scrollingSector"))
--  stdbox(54,98)
--  movestep(2,1)
  movestep(1,0)
  linesector(96,lowerfloor,cellRevivedBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(96,raisefloor,cellKilledBlockerTag(x,y),get("scrollingSector"))
  movestep(2,0)
  linesector(96,raisefloor,cellDeadBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(96,244,cellDeadTag(x,y),get("scrollingSector"))
  movestep(46,0)
  forcesector(cellAliveBlockerSector(x,y))
  ibox(25,128,161,1,96)
  movestep(19,-16)
}

killCellBlock(x, y) {
  !killCellBlock
  sectortype(0,killCellTag(x,y))
  stdboxwithfrontline(11,32,raisefloor,cellStartedTag(x,y))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)
  forcesector(get("scrollingSector"))
  stdbox(21,32)
  movestep(1,6)
  linesector(20,lowerfloor,cellFinishedTag(x,y),get("scrollingSector"))
  movestep(11,2)
  !allFinished
  forvar("neighbIx",0,7,
    forcesector(cellFinishedSector(x,y,get("neighbIx")))
    ibox(0,42,161,1,1)
    movestep(0,2)
  )
  ^allFinished
  movestep(-9,-2)
  linesector(20,raisefloor,cellDeadBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,cellAliveBlockerTag(x,y),get("scrollingSector"))
  movestep(11,0)
  forcesector(cellKilledBlockerSector(x,y))
  ibox(0,128,161,1,20)
  movestep(-9,0)
  linesector(20,208,allNbrsFinishedTag(x,y),get("scrollingSector"))
  ^killCellBlock
  movestep(32,0)
}
reviveCellBlock(x, y) {
  !reviveCellBlock
  sectortype(0,reviveCellTag(x,y))
  stdboxwithfrontline(11,32,raisefloor,cellStartedTag(x,y))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)
  forcesector(get("scrollingSector"))
  stdbox(21,32)
  movestep(1,6)
  linesector(20,lowerfloor,cellFinishedTag(x,y),get("scrollingSector"))
  movestep(11,2)
  !allFinished
  forvar("neighbIx",0,7,
    forcesector(cellFinishedSector(x,y,get("neighbIx")))
    ibox(0,42,161,1,1)
    movestep(0,2)
  )
  ^allFinished
  movestep(-9,-2)
  linesector(20,raisefloor,cellAliveBlockerTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,lowerfloor,cellDeadBlockerTag(x,y),get("scrollingSector"))
  movestep(11,0)
  forcesector(cellRevivedBlockerSector(x,y))
  ibox(0,128,161,1,20)
  movestep(-9,0)
  linesector(20,208,allNbrsFinishedTag(x,y),get("scrollingSector"))
  ^reviveCellBlock
  movestep(32,0)
}
keepCellBlock(x, y) {
  !keepCellBlock
  sectortype(0,keepCellTag(x,y))
  stdboxwithfrontline(11,32,raisefloor,cellStartedTag(x,y))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)
  forcesector(get("scrollingSector"))
  stdbox(21,32)
  movestep(1,6)
  linesector(20,lowerfloor,cellFinishedTag(x,y),get("scrollingSector"))
  movestep(11,2)
  !allFinished
  forvar("neighbIx",0,7,
    forcesector(cellFinishedSector(x,y,get("neighbIx")))
    ibox(0,42,161,1,1)
    movestep(0,2)
  )
  ^allFinished
  movestep(-9,-2)
  linesector(20,208,allNbrsFinishedTag(x,y),get("scrollingSector"))
  ^keepCellBlock  
  movestep(32,0)
}
--waitAllNbrsFinishedBlock(x,y) {
--  !waitAll
--  sectortype(0,waitAllNbrsFinishedTag(x,y))
--  stdboxwithfrontline(11,22,raisefloor,cellStartedTag(x,y))
--  movestep(10,11)
--  teleportlanding
--  thingangle(rotatedAngle(angle_north))
--  movestep(1,-11)
--  forcesector(get("scrollingSector"))
--  stdbox(26,22)
--  movestep(1,1)
--  linesector(20,lowerfloor,cellFinishedTag(x,y),get("scrollingSector"))
--  movestep(11,-1)
--  !allFinished
--  movestep(0,1)
--  forvar("neighbIx",0,7,
--    forcesector(cellFinishedSector(x,y,get("neighbIx")))
--    ibox(0,42,161,1,1)
--    movestep(0,2)
--  )
--  ^allFinished
--  movestep(2,1)
--  linesector(20,244,allNbrsFinishedTag(x,y),get("scrollingSector"))
--  ^waitAll
--  movestep(37,0)
--}

waitAllNbrsStartedBlock(x,y) {
  !waitAll
  sectortype(0,allNbrsFinishedTag(x,y))
  stdboxwithfrontline(11,32,lowerfloor,cellStartedTag(x,y))
  movestep(10,16)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(1,-16)  
  forcesector(get("scrollingSector"))
  stdbox(21,32)
--  movestep(10,1)
--  fliplinesector(20,0,allNbrsFinishedTag(x,y),get("scrollingSector"))
--  movestep(1,0)
--  linesector(20,lowerfloor,cellStartedTag(x,y),get("scrollingSector"))
  movestep(11,8)
  !allStarted
  forvar("neighbIx",0,7,
    forcesector(cellStartedSector(x,y,get("neighbIx")))
    sectortype(0,cat2("cellStarted",neighbourString(x,y,get("neighbIx"))))
    ibox(0,42,161,1,1)
    movestep(0,2)
  )
  ^allStarted
  movestep(-9,-2)
  linesector(20,raisefloor,cellFinishedTag(x,y),get("scrollingSector"))
  movestep(1,0)
  linesector(20,244,startCheckTag(x,y),get("scrollingSector"))
  ^waitAll
  movestep(32,0)
}

linesector(len,type,tag,sectorIndex) {
  forcesector(sectorIndex)
  linetype(type,tag) step(0,len)
  linetype(0,0) step(0,neg(len))
  rightsector(0,128,161)
}
fliplinesector(len,type,tag,sectorIndex) {
  forcesector(sectorIndex)
  movestep(0,len)
  linetype(type,tag) step(0,neg(len))
  linetype(0,0) step(0,len)
  movestep(0,neg(len))
  rightsector(0,128,161)
}

barrelStart(x,y) {
  forcesector(get("scrollingSector"))
  stdbox(22,22)
  movestep(10,11)
  barrel
--  if(and(eq(x,1),eq(y,1)),
  thing
--  )
  movestep(1,-10)
  linesector(20,208,keepCellTag(x,y),get("scrollingSector"))
  movestep(9,0)
  forcesector(get("barrelStartBlockerSector"))
  ibox(25,128,161,1,20)
  movestep(2,-1)
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

initializeLineTags {
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
      set(cat3("cellFinished",x,y),newtag)
      set(cat3("cellStarted",x,y),newtag)
      set(cat3("startCheck",x,y),newtag)
--      set(cat3("waitAllNbrsFinished",x,y),newtag)
      set(cat3("allNbrsFinished",x,y),newtag)
      forvar("neighbIx",0,7,
        forvar("neighbCnt",0,3,
          set(cat5("check",get("x"),get("y"),get("neighbIx"),get("neighbCnt")),newtag)
          if(lessthan(get("neighbCnt"),3),
            set(cat5("checkOk",get("x"),get("y"),get("neighbIx"),get("neighbCnt")),newtag))
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
cellFinishedTag(x,y) {
  get(cat3("cellFinished",x,y))
}
cellStartedTag(x,y) {
  get(cat3("cellStarted",x,y))
}
startCheckTag(x,y) {
  get(cat3("startCheck",x,y))
}
--waitAllNbrsFinishedTag(x,y) {
--  get(cat3("waitAllNbrsFinished",x,y))
--}
allNbrsFinishedTag(x,y) {
  get(cat3("allNbrsFinished",x,y))
}
cellFinishedSector(x,y,neighbIx) {
  get(cat2("cellFinishedSector",neighbourString(x,y,neighbIx)))
}
cellStartedSector(x,y,neighbIx) {
  get(cat2("cellStartedSector",neighbourString(x,y,neighbIx)))
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
stdbox(x,y) {
  box(0,128,161,x,y)
}
stdboxwithfrontline(x,y,type,tag) {
  linetype(0,0) straight(x)
  linetype(type,tag) right(y)
  linetype(0,0) right(x)
  right(y)
  rightsector(0,128,161)
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
