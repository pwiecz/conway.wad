#"boom.h"
#"lines.h"
#"monsters.h"
#"spawns.h"
#"standard.h"

rowCount {13}
colCount {13}
ceilingHeight { add(mul(rowCount,128),300) }
/* Dimensions of the area performing the actual simulation
   Everything should ideally be aligned to the blockmap boundaries -
   this way collision detection works reliably, and mancubi are blocking
   all the teleporting lines. */
simulator_x_size { mul(128,rowCount) }
-- 320 = 128+128+32+32
simulator_y_size { mul(320,colCount) }
control_sector_x_size { add(1, mul(2, colCount)) }
control_sector_y_size { mul(8, rowCount) }
-- dimensions of the main area where the player can move (not counting the vertical board)
playbox_x_size{ add(mul(rowCount,226),128) }
playbox_y_size{ add(mul(colCount,226),500) }
vertical_board_x_size{ mul(128,colCount) }
vertical_board_y_size{ add(mul(8, rowCount), 164) }
-- scrollSpeed { 34 } -- max speed that works reliably in PrBoom+
-- scrollSpeed { 32 } -- max speed that works reliably in GzDoom
scrollSpeed { 32 }
barrel { setthing(2035) }
raisefloor { 24617 }
lowerfloor { 24809 }
lowerfloor1 { 24808 }
lineteleport { 267 }
thingteleport { 269 }

/* Draw external walls and record positions of bottom-left corners of various subsectors.
   All the things and lines will be placed inside those walls
   Don't create any sector.
   This draws all the lindefs with opaque midtexture and let's us use empty midtexture
   for all the remaining linedefs, which helps ameliorate problems with midtexture bleeding.
*/ 
drawWalls() {
  undefx
  mid("GRAY1")
  linetype(253, $scroll_north) straight(scrollSpeed)
  linetype(0,0) straight(sub(simulator_x_size, scrollSpeed))
  !control_sector_position
  straight(control_sector_x_size)
  right(control_sector_y_size)
  right(control_sector_x_size)
  left(sub(simulator_y_size, control_sector_y_size))
  left(sub(playbox_x_size, simulator_x_size))
  right(playbox_y_size)
  right(sub(playbox_x_size,vertical_board_x_size))
  left(vertical_board_y_size)
  right(vertical_board_x_size)
  right(vertical_board_y_size)
  rotright
  !vertical_board_position
  left(playbox_y_size)
  rotright
  !playbox_position
  left(simulator_y_size)
  rotright
}

main {
  /* Rotate the map to make it all fit in the positive quarter of the doom coordinate space.
     With the least coordinate at (0,0), this way we can assure that all the simulator blocks
     are aligned to blockmap boundaries.
  */
  turnaround   
  initializeTags
  top("-")
  mid("-")  
  !origin
  drawWalls()
  xoff(0)
  yoff(0)

  ^control_sector_position
  mid("-")
  controlSector()

  -- Close off the simulator sector
  ^playbox_position
  mid("-")
  impassable
  straight(simulator_x_size)
  impassable
  sectortype(0,$scroll_north)
  leftsector(0,ceilingHeight,200)
  set("scrollingSector",lastsector)

  ^origin

  !checkers
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !block
      checkerForCell(get("x"),get("y"))
      ^block
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
      !cell
      aliveCellBlock(get("x"),get("y"))
      ^cell
      movestep(128,0)
    )
    ^column
    movestep(0,128)
  )
  ^aliveCells  
  movestep(0,mul(128,colCount))

  !ladders
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !cell
      checkLadderForCell(get("x"),get("y"))
      ^cell
      movestep(128,0)
    )
    ^column
    movestep(0, 32)
  )
  ^ladders
  movestep(0,mul(32,colCount))

  !cellsFinished
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !cell
      cellFinishedBlock(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^cellsFinished
  movestep(mul(32,rowCount),0)

  !waitNbrsCommitted
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !cell
      waitAllNbrsCommittedBlock(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^waitNbrsCommitted
  movestep(mul(32,rowCount),0)

  !waitNbrsStarted
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !cell
      waitAllNbrsStartedBlock(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^waitNbrsStarted
  movestep(mul(32,rowCount),0)

  !barrels
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !cell
      barrelStart(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^barrels

  ^playbox_position
  mid("-")
  movestep(32, 17)
  player1start
  thingangle(rotatedAngle(angle_east))
  movestep(-32, 15)

  yoff(32)
  bot("BROWN96")
  right(32)
  left(8)
  xoff(48)
  bot("SW1BROWN")
  linetype(24778,barrelStartBlockerTag)
  left(32)
  linetype(0,0)
  bot("BROWN96")
  left(8)
  leftsector(96,ceilingHeight,200)
  turnaround
  yoff(0)
  xoff(0)

  -- Close off the playbox sector.
  ^vertical_board_position
  mid("-")
  straight(vertical_board_x_size)
  sectortype(0,0)
  leftsector(0,ceilingHeight,200)

  ^playbox_position
  mid("-")

  movestep(127, 128)
  bot("MARBGRAY")
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      forcesector(stepSector(x,y))
      linetype(lowerfloor1,cellDeadBlockerTag(x,y))
      ibox(0,0,0,128,128)
      popsector
      movestep(226,0)
    )
    ^column
    movestep(0,226)
  )
  linetype(0,0)
  movestep(0,add(mul(colCount,226),500))


  ^vertical_board_position
  mid("-")
  forvar("y",0,sub(rowCount,1),
    bot("MARBFAC3")
    riserstep(y,0,0,"MARBFAC3")
    movestep(128,0)
  )
  ^vertical_board_position
  mid("-")
  movestep(0,4)
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      riserstep(y,mul(x,128),marbTag(x,y),"BIGDOOR7")
      movestep(0,4)
      riserstep(y,mul(add(x,1),128),0,"MARBFAC3")
      movestep(128,-4)
    )
    ^column
    movestep(0,8)
  )


  linetype(exit_w1_normal,0)
  box(mul(128,colCount),ceilingHeight,200,vertical_board_x_size, 32)
  movestep(0,32)
  floor("F_SKY1")
  box(sub(mul(colCount,128),16),ceilingHeight,200,mul(128,colCount),128)
}

riserstep(y,floor,tag,tex) {
  bot(tex)
  straight(128)
  bot("DOORTRAK")
  right(4)
  bot(tex)
  right(128)
  bot("DOORTRAK")
  right(4)
  sectortype(0,tag)
  rightsector(floor,ceilingHeight,200)
  rotright
}

controlSector() {
  !row
  sectortype(0,barrelStartBlockerTag)
  box(25,ceilingHeight,200,1,1)
  set("barrelStartBlockerSector",lastsector)
  movestep(0,1)
  sectortype(0,0)
  box(25,ceilingHeight,200,1,sub(control_sector_y_size, 1))
  set("raisedSector",lastsector)
  ^row
  movestep(1,0)
  forvar("y",0,sub(rowCount,1),
    !row
    forvar("x",0,sub(colCount,1),
      sectortype(0,cellDeadBlockerTag(x,y))
      box(25,ceilingHeight,200,1,1)
      set(cat3("cellDeadBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellAliveBlockerTag(x,y))
      box(25,ceilingHeight,200,1,1)
      set(cat3("cellAliveBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellKilledBlockerTag(x,y))
      box(0,ceilingHeight,200,1,1)
      set(cat3("cellKilledBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellRevivedBlockerTag(x,y))
      box(25,ceilingHeight,200,1,1)
      set(cat3("cellRevivedBlockerSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,stepTag(x,y))
      box(13,ceilingHeight,200,1,1)
      set(cat3("stepSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellFinishedTag(x,y))
      box(25,ceilingHeight,200,1,1)
      set(cat3("cellFinishedSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellCommittedTag(x,y))
      box(25,ceilingHeight,200,1,1)
      set(cat3("cellCommittedSector",x,y),lastsector)
      movestep(0,1)
      sectortype(0,cellStartedTag(x,y))
      box(25,ceilingHeight,200,1,1)
      set(cat3("cellStartedSector",x,y),lastsector)
      movestep(0,1)
    )
    ^row
    movestep(1,0)
    forcesector(get("raisedSector"))
    box(0,0,0,1,control_sector_y_size)
    movestep(1,0)
  )
}

checkLadderStep(x, y, nbrIx, nbrCnt) {
  if(lessthaneq(1,nbrCnt),
    movestep(1,0)
    lineleft(20,0,checkeeOkLineTag(x,y,sub(nbrIx,1),sub(nbrCnt,1)))
  )
  movestep(1,0)
  lineright(20,lineteleport,checkeeLineTag(x,y,nbrIx,nbrCnt))
}

checkLadderForCell(x, y) {
  movestep(10,6)
  lineleft(20,0,startCheckTag(x,y))
  fori(0, 6,
    checkLadderStep(x, y, i, 0)
  )
  movestep(1,0)
  lineright(20,thingteleport,killCellTag(x,y))

  fori(1,7,
    checkLadderStep(x, y, i, 1)
  )
  movestep(1,0)
  lineright(20,thingteleport,killCellTag(x,y))

  fori(2,7,
    checkLadderStep(x, y, i, 2)
  )
  movestep(1,0)
  lineright(20,thingteleport,keepCellTag(x,y))

  fori(3,7,
    checkLadderStep(x, y, i, 3)
  )
  movestep(1,0)
  lineright(20,thingteleport,reviveCellTag(x,y))
}

checkerForCell(x, y) {
  movestep(0,14)
  set("nbrIx",0)
  !nbrs
  forvar("col",0,1,
    !nbrColumn
    forvar("row",0,3,
      movestep(10,0)
      lineleft(2,0,checkerLineTag(x,y,get("nbrIx"),0))
      movestep(1,0)
      ifelse(eq(get("nbrIx"),7),
        lineright(2,thingteleport,get(cat2("killCell",invNeighbourString(x,y,get("nbrIx"))))),
        lineright(2,lineteleport,checkerOkLineTag(x,y,get("nbrIx"),0))
      )
      movestep(1,0)
      lineleft(2,0,checkerLineTag(x,y,get("nbrIx"),1))
      movestep(1,0)
      ifelse(eq(get("nbrIx"),7),
        lineright(2,thingteleport,get(cat2("keepCell",invNeighbourString(x,y,get("nbrIx"))))),
        lineright(2,lineteleport,checkerOkLineTag(x,y,get("nbrIx"),1))
      )
      movestep(1,0)
      lineleft(2,0,checkerLineTag(x,y,get("nbrIx"),2))
      movestep(1,0)
      ifelse(eq(get("nbrIx"),7),
        lineright(2,thingteleport,get(cat2("reviveCell",invNeighbourString(x,y,get("nbrIx"))))),
        lineright(2,lineteleport,checkerOkLineTag(x,y,get("nbrIx"),2))
      )
      movestep(1,0)
      lineleft(2,0,checkerLineTag(x,y,get("nbrIx"),3))
      movestep(1,0)
      lineright(2,thingteleport,get(cat2("killCell",invNeighbourString(x,y,get("nbrIx")))))
      movestep(11,0)
      inc("nbrIx",1)
    )
    ^nbrColumn
    movestep(0,98)
  )
  ^nbrs
  movestep(56,50)
  mancubus
  thingangle(rotatedAngle(angle_west))
  movestep(-4,-10)
  lineleft(20,0,cellDeadTag(x,y))
  movestep(1,0)
  lineright(20,raisefloor,cellRevivedBlockerTag(x,y))
  movestep(1,0)
  lineright(20,lowerfloor,cellKilledBlockerTag(x,y))
  movestep(1,0)
  lineright(20,lowerfloor,marbTag(x,y))
  movestep(2,0)
  lineright(20,raisefloor,cellAliveBlockerTag(x,y))
  movestep(1,0)
  lineright(20,lineteleport,cellAliveTag(x,y))
  movestep(46,0)
  forcesector(cellDeadBlockerSector(x,y))
  ibox(0,0,0,1,20)
  popsector
}

aliveCellBlock(x,y) {
  sectortype(0,0)
  movestep(48,16)
  lineleft(96,0,cellAliveTag(x,y))
  movestep(1,0)
  lineright(96,raisefloor,stepTag(x,y))
  movestep(1,0)
  lineright(96,raisefloor,cellKilledBlockerTag(x,y))
  movestep(1,0)
  lineright(96,lowerfloor,cellRevivedBlockerTag(x,y))
  movestep(1,0)
  lineright(96,raisefloor,marbTag(x,y))
  movestep(2,0)
  lineright(96,raisefloor,cellDeadBlockerTag(x,y))
  movestep(1,0)
  lineright(96,lineteleport,cellDeadTag(x,y))
  movestep(46,0)
  forcesector(cellAliveBlockerSector(x,y))
  ibox(0,0,0,1,96)
  popsector
}

cellFinishedBlock(x, y) {
  movestep(9,10)
  sectortype(0,killCellTag(x,y))
  stdboxwithfrontline(2,2,raisefloor,cellCommittedTag(x,y))
  movestep(1,1)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(-1,1)
  sectortype(0,keepCellTag(x,y))
  stdboxwithfrontline(2,8,lowerfloor,cellFinishedTag(x,y))
  movestep(1,4)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(-1,4)
  sectortype(0,reviveCellTag(x,y))
  stdboxwithfrontline(2,2,raisefloor,cellCommittedTag(x,y))
  movestep(1,1)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(-1,-11)
  forcesector(get("scrollingSector"))
  invbox(0,0,0,2,12)
  movestep(13,2)
  !allFinished
  forvar("nbrIx",0,7,
    forcesector(cellNbrFinishedSector(x,y,get("nbrIx")))
    xoff(mod(get("nbrIx"),2))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allFinished
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  xoff(0)
  movestep(-9,-11)
  
  lineright(2,raisefloor,cellDeadBlockerTag(x,y))
  movestep(1,0)
  lineright(2,lowerfloor,cellAliveBlockerTag(x,y))
  movestep(11,0)
  forcesector(cellKilledBlockerSector(x,y))
  ibox(0,0,0,1,2)
  popsector
  movestep(-12,28)
  lineright(2,raisefloor,cellAliveBlockerTag(x,y))
  movestep(1,0)
  lineright(2,lowerfloor,cellDeadBlockerTag(x,y))
  movestep(11,0)
  forcesector(cellRevivedBlockerSector(x,y))
  ibox(0,0,0,1,2)
  popsector
  movestep(-9,-23)
  lineright(20,thingteleport,allNbrsFinishedTag(x,y))
}
waitAllNbrsCommittedBlock(x,y) {
  movestep(9,6)
  sectortype(0,allNbrsFinishedTag(x,y))
  stdiboxwithfrontline(2,20,raisefloor,cellStartedTag(x,y))
  movestep(1,10)
  teleportlanding
  thingangle(rotatedAngle(angle_north))
  movestep(2,-10)  
  lineright(20,lowerfloor,cellCommittedTag(x,y))
  movestep(11,6)
  !allCommitted
  forvar("nbrIx",0,7,
    forcesector(cellNbrCommittedSector(x,y,get("nbrIx")))
    xoff(mod(get("nbrIx"),2))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allCommitted
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  xoff(0)
  movestep(-9,-6)

  lineright(20,lineteleport,allNbrsCommittedTag(x,y))
}

waitAllNbrsStartedBlock(x,y) {
  movestep(10, 6)
  lineleft(20,0,allNbrsCommittedTag(x,y))
  movestep(1,0)
  lineright(20,raisefloor,cellFinishedTag(x,y))
  movestep(1,0)
  lineright(20,lowerfloor,cellStartedTag(x,y))
  movestep(11,6)
  !allStarted
  forvar("nbrIx",0,7,
    forcesector(cellNbrStartedSector(x,y,get("nbrIx")))
    xoff(mod(get("nbrIx"),2))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^allStarted
  forcesector(get("scrollingSector"))
  invbox(0,0,0,1,8)
  xoff(0)
  movestep(-9,-6)

  lineright(20,lineteleport,startCheckTag(x,y))
}

lineright(len,type,tag) {
  forcesector(get("scrollingSector"))
  linetype(type,tag) step(0,len)
  linetype(0,0) step(0,neg(len))
  rightsector(0,0,0)
}
lineleft(len,type,tag) {
  forcesector(get("scrollingSector"))
  movestep(0,len)
  linetype(type,tag) step(0,neg(len))
  linetype(0,0) step(0,len)
  movestep(0,neg(len))
  rightsector(0,0,0)
}

barrelStart(x,y) {
  movestep(10,16)
  barrel
  thing
  movestep(1,-10)
  lineright(20,raisefloor,stepTag(x,y))
  movestep(1,0)
  lineright(20,thingteleport,keepCellTag(x,y))
  movestep(8,0)
  forcesector(get("barrelStartBlockerSector"))
  ibox(0,0,0,1,20)
  popsector
}

neighbourString(x, y, nbrIx) {
  ifelse(eq(nbrIx,0),
    cat2(subx1(x),suby1(y)),
    ifelse(eq(nbrIx,1),
      cat2(subx1(x),y),
      ifelse(eq(nbrIx,2),
        cat2(subx1(x),addy1(y)),
	ifelse(eq(nbrIx,3),
          cat2(x,suby1(y)),
	  ifelse(eq(nbrIx,4),
            cat2(x,addy1(y)),
	    ifelse(eq(nbrIx,5),
              cat2(addx1(x),suby1(y)),
	      ifelse(eq(nbrIx,6),
                cat2(addx1(x),y),
		cat2(addx1(x),addy1(y)))))))))
}
invNeighbourString(x, y, nbrIx) {
  neighbourString(x,y,sub(7,nbrIx))
}
subx1(x) {
  mod(add(x,sub(colCount,1)),colCount)
}
addx1(x) {
  mod(add(x,1),colCount)
}
suby1(y) {
  mod(add(y,sub(rowCount,1)),rowCount)
}
addy1(y) {
  mod(add(y,1),colCount)
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
      set(cat3("cellFinished",x,y),newtag)
      set(cat3("cellStarted",x,y),newtag)
      set(cat3("cellCommitted",x,y),newtag)
      set(cat3("startNextTurn",x,y),newtag)
      set(cat3("startCheck",x,y),newtag)
      set(cat3("allNbrsFinished",x,y),newtag)
      set(cat3("allNbrsCommitted",x,y),newtag)
      set(cat3("marb",x,y),newtag)
      set(cat3("step",x,y),newtag)
      forvar("nbrIx",0,7,
        forvar("nbrCount",0,3,
          set(cat5("check",get("x"),get("y"),get("nbrIx"),get("nbrCount")),newtag)
          if(and(lessthan(get("nbrCount"),3),lessthan(get("nbrIx"),7)),
            set(cat5("checkOk",get("x"),get("y"),get("nbrIx"),get("nbrCount")),newtag))
        )
      )
    )
  )
}
barrelStartBlockerTag {
  get("barrelStartBlocker")
}

checkeeLineTag(x,y,nbrIx,nbrCount) {
  get(cat4("check",neighbourString(x,y,nbrIx),nbrIx,nbrCount))
}
checkeeOkLineTag(x,y,nbrIx,nbrCount) {
  get(cat4("checkOk",neighbourString(x,y,nbrIx),nbrIx,nbrCount))
}
checkerLineTag(x,y,nbrIx,nbrCount) {
  get(cat5("check",x,y,nbrIx,nbrCount))
}
checkerOkLineTag(x,y,nbrIx,nbrCount) {
  get(cat5("checkOk",x,y,nbrIx,nbrCount))
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
allNbrsCommittedTag(x,y) {
  get(cat3("allNbrsCommitted",x,y))
}
cellFinishedTag(x,y) {
  get(cat3("cellFinished",x,y))
}
cellCommittedTag(x,y) {
  get(cat3("cellCommitted",x,y))
}
cellStartedTag(x,y) {
  get(cat3("cellStarted",x,y))
}
cellNbrFinishedSector(x,y,nbrIx) {
  get(cat2("cellFinishedSector",neighbourString(x,y,nbrIx)))
}
cellNbrCommittedSector(x,y,nbrIx) {
  get(cat2("cellCommittedSector",neighbourString(x,y,nbrIx)))
}
cellNbrStartedSector(x,y,nbrIx) {
  get(cat2("cellStartedSector",neighbourString(x,y,nbrIx)))
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
stepTag(x,y) {
  get(cat3("step",x,y))
}
stepSector(x,y) {
  get(cat3("stepSector",x,y))
}
stdbox(x,y) {
  box(0,ceilingHeight,200,x,y)
}
stdiboxwithfrontline(x,y,type,tag) {
  linetype(0,0) straight(x)
  linetype(type,tag) right(y)
  linetype(0,0) right(x)
  right(y)
  innerrightsector(0,ceilingHeight,200)
  rotright
}
stdboxwithfrontline(x,y,type,tag) {
  linetype(0,0) straight(x)
  linetype(type,tag) right(y)
  linetype(0,0) right(x)
  right(y)
  rightsector(0,ceilingHeight,200)
  rotright
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
