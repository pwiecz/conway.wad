#"lines.h"
#"monsters.h"
#"spawns.h"
#"standard.h"

rowCount {4}
colCount {4}
scrollSpeed {10}
barrel { setthing(2035) }
burningbarrel { setthing(70) }

main {
  turnaround
  undefx	
  linetype(253, $scroll_north) straight(scrollSpeed)
  linetype(0,0) right(1)
  right(scrollSpeed)
  right(1)
  rightsector(0,0,0)
  rotright
  movestep(0,1)
  
  initializeLineTags  

  sectortype(0, $scroll_north)

  !barrels
  forvar("x",0,sub(rowCount,1),
    !column
    forvar("y",0,sub(colCount,1),
      barrelStart(get("x"),get("y"))
    )
    ^column
    movestep(0,20)
  )
  ^barrels
  movestep(0,mul(20,colCount))
  !ladders
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      checkLadderForCell(get("x"),get("y"))
    )
    ^column
    movestep(0, 21)
  )
  ^ladders
  movestep(0,mul(21,colCount))
  !checkers
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      !checker
      checkerForCell(get("x"),get("y"))
      ^checker
      movestep(72,0)
    )      
    ^column
    movestep(0,70)
  )
  ^checkers
  movestep(0,mul(70,colCount))
  !aliveCells
  forvar("x",0,sub(colCount,1),
    !column
    forvar("y",0,sub(rowCount,1),
      aliveCellBlock(get("x"),get("y"))
    )
    ^column
    movestep(0,32)
  )
  ^aliveCells
  movestep(0,mul(32,colCount))
  sectortype(0,0)
  stdbox(1000, 1000)
  movestep(32, 64)

  player1start
  thingangle(rotatedAngle(angle_west))

  movestep(100,-1)
  linetype(floor_wr_down_LnF, $blocker)
  right(32)
  left(4)
  left(32)
  left(4)
  innerleftsector(10,128,161)
  turnaround

}

checkLadderStep(x, y, neighbIx, neighbCnt) {
  if(lessthaneq(1,neighbCnt),
    stdboxwithfrontline(1,20,0,checkeeOkLineTag(x,y,sub(neighbIx,1),sub(neighbCnt,1)))
    movestep(1,0)
  )
  stdboxwithfrontline(1,20,244,checkeeLineTag(x,y,neighbIx,neighbCnt))
  movestep(1, 0)
}

checkLadderForCell(x, y) {
  box(0,128,161,68,1)
  movestep(0,1)
  -- place for the back half of the barrel
  sectortype(0,starterTag(x,y))
  stdboxwithfrontline(11,20,244,checkeeLineTag(x,y,0,0))
  sectortype(0,$scroll_north)
  movestep(10,10)
  teleportlanding
  thing
  thingangle(rotatedAngle(angle_north))
  movestep(1,-10)
  fori(1, 6,
    checkLadderStep(x, y, i, 0)
  )
  stdboxwithfrontline(1,20,
--  97,killCellTag(x,y))
    269,starterTag(x,y))
  movestep(1, 0)
  fori(1,7,
    checkLadderStep(x, y, i, 1)
  )
  stdboxwithfrontline(1,20,97,killCellTag(x,y))
  movestep(1, 0)

  fori(2,7,
    checkLadderStep(x, y, i, 2)
  )
  stdboxwithfrontline(1,20,97,keepCellTag(x,y))
  movestep(1, 0)

  fori(3,7,
    checkLadderStep(x, y, i, 3)
  )
  stdboxwithfrontline(1,20,97,reviveCellTag(x,y))
  movestep(1, 0)
  --headroom for front of the barrel
  stdbox(11, 20)
  movestep(11,-1)
}

checkerForCell(x, y) {
  -- room for left part of barrels to move over
  stdbox(72,10)
  movestep(0,10)
  set("neighbIx",0)
  forvar("col",0,2,
    !neighbourColumn
    stdbox(10,4)
    movestep(10,0)
    forvar("row",0,2,
      ifelse(and(eq(get("col"),1),eq(get("row"),1)),
        stdbox(24,4) movestep(24,0), -- TODO: place for the blocker
	stdboxwithfrontandbackline(1,2,
          244,checkerOkLineTag(x,y,get("neighbIx"),0),
          0,checkerLineTag(x,y,get("neighbIx"),0))
	movestep(0,2)
	stdboxwithfrontandbackline(1,2,
          244,checkerOkLineTag(x,y,get("neighbIx"),1),
          0,checkerLineTag(x,y,get("neighbIx"),1))
	movestep(1,-2)
	stdboxwithfrontline(1,2,
	  0,checkerLineTag(x,y,get("neighbIx"),2))
	movestep(1,0)
	stdboxwithfrontline(1,2,
	  244,checkerOkLineTag(x,y,get("neighbIx"),2))
	movestep(-1,2)
	stdboxwithfrontline(1,2,
	  0,checkerLineTag(x,y,get("neighbIx"),3))
	movestep(1,0)
    	stdboxwithfrontline(1,2,
          97,get(cat2("killCell",invNeighbourString(x,y,get("neighbIx")))))
        movestep(1,-2)
        ifelse(lessthan(get("row"),2),
          stdbox(21,4)
	  movestep(21,0),
          stdbox(11,4)
	  movestep(11,0)
	)
        inc("neighbIx",1)
      )
    )
    if(eq(get("col"),1),
      movestep(-21,1)
      sectortype(0,cellDeadBlockerTag(x,y))
      ibox(1,16,161,1,2)
      sectortype(0,$scroll_north)
      movestep(-16,1)
      burningbarrel
      thing
    )
    ^neighbourColumn
    movestep(0,4)
    ifelse(lessthan(get("col"),2),
      stdbox(72,19) movestep(0,19),
      stdbox(72,10) movestep(0,10)
    )
  )
}

barrelStart(x,y) {
  sectortype(0,$scroll_north)
  stdboxwithfrontline(11,20,269,starterTag(x,y))
  movestep(10,10)
  barrel
  thing
  movestep(1,-10)
  box(0,128,161,11,20)
  movestep(11,0)
}

aliveCellBlock(x,y) {
  sectortype(0,cellAliveTag(x,y))
  stdboxwithfrontline(17,32,269,cellDeadTag(x,y))
  sectortype(0,$scroll_north)
  movestep(16,16)
  teleportlanding
  thing
  movestep(1,-16)
  stdbox(15,32)
  movestep(15,0)
  sectortype(0,cellAliveBlockerTag(x,y))
  box(25,128,161,1,32)
  sectortype(0,$scroll_north)
  movestep(1,0)
}

neighbourString(x, y, neighbIx) {
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
  forvar("x",0,sub(colCount,1),
    forvar("y",0,sub(rowCount,1),
      set(cat3("starter",x,y),newtag)
      set(cat3("killCell",x,y),newtag)
      set(cat3("keepCell",x,y),newtag)
      set(cat3("reviveCell",x,y),newtag)
      set(cat3("cellDead",x,y),newtag)
      set(cat3("cellDeadBlocker",x,y),newtag)
      set(cat3("cellAlive",x,y),newtag)
      set(cat3("cellAliveBlocker",x,y),newtag)
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
starterTag(x,y) {
  get(cat3("starter",x,y))
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
cellAliveTag(x,y) {
  get(cat3("cellAlive",x,y))
}
cellAliveBlockerTag(x,y) {
  get(cat3("cellAliveBlocker",x,y))
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
stdboxwithfrontandbackline(x,y,fronttype,fronttag,backtype,backtag) {
  linetype(0,0) straight(x)
  linetype(fronttype,fronttag) right(y)
  linetype(0,0) right(x)
  linetype(backtype,backtag) right(y)
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

forj(from, to, body) {
    set("j", from)
    for(from, to,
        body
        inc("j",1)
    )
}
j { get("j") }
fork(from, to, body) {
    set("k", from)
    for(from, to,
        body
        inc("k",1)
    )
}
k { get("k") }
forl(from, to, body) {
    set("l", from)
    for(from, to,
        body
        inc("l",1)
    )
}
l { get("l") }
forvar(var,from,to,body) {
  set(var, from)
  for(from, to,
    body
    inc(var,1)
  )
}
mod(n,d) {
 sub(n,mul(div(n,d),d))
}
rotatedAngle(angle) {
  ifelse(eq(getorient,0),
    angle,
    ifelse(eq(getorient,1),
      mod(add(angle,90),360),
      ifelse(eq(getorient,2),
        mod(add(angle,180),360),
	mod(add(angle,270),360))))
}