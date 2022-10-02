#"lines.h"
#"monsters.h"
#"spawns.h"
#"standard.h"

rowCount {2}
colCount {2}
scrollSpeed {128}

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

  forvar("x",0,sub(rowCount,1),
    !column
    forvar("y",0,sub(colCount,1),
      !ladder
      checkLadderForCell(get("x"),get("y"))
      ^ladder
      movestep(0, 21)
      checkerForCell(get("x"),get("y"))
      ^ladder
      movestep(71, 0)
    )
    ^column
    movestep(0, 103)
  )

  sectortype(0,0)
  stdbox(1000, 1000)
  movestep(32, 64)

  player1start
  thing

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
    step(1, 0)
    linetype(0, checkeeOkLineTag(x,y,sub(neighbIx,1),sub(neighbCnt,1))) right(20)
    linetype(0, 0) right(1)
    right(20)
    rightsector(0, 128, 161)
    rotright
    movestep(1, 0)
  )

  step(1, 0)
  linetype(244, checkeeLineTag(x,y,neighbIx,neighbCnt)) right(20)
  linetype(0, 0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)
}

checkLadderForCell(x, y) {
  !startLadder
  box(0,128,161,71,1)
  movestep(0,1)
  -- place for the back half of the barrel
  step(10,0)
  linetype(0,starterTag(x,y)) flipright(20)
  linetype(0,0) right(10)
  right(20)
  rightsector(0,128,161)
  rotright
  movestep(10,0)
  movestep(0,10)
  -- barrel
  setthing(2035)
  thing
  movestep(0,-10)
  fori(0, 6, 
    checkLadderStep(x, y, i, 0)
  )
  step(1, 0)
--  linetype(97,killCellTag(x,y)) right(20)
--  linetype(269,starterTag(x,y)) right(20)
  linetype(244,starterTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)

  -- headroom to make the barrel fit before the blocker
  stdbox(2,20)
  movestep(2,0)
  
  sectortype(0,$blocker)
  box(1, 42, 161, 1, 20)
  sectortype(0, $scroll_north)

  movestep(1, 0)

  fori(1,7,
    checkLadderStep(x, y, i, 1)
  )
  step(1, 0)
  linetype(97,killCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)

  fori(2,7,
    checkLadderStep(x, y, i, 2))
  step(1, 0)
  linetype(97,keepCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)

  fori(3,7,
    checkLadderStep(x, y, i, 3))
  step(1, 0)
  linetype(97,reviveCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)
  --headroom for front of the barrel
  stdbox(11, 20)
  ^startLadder
--  movestep(0,20)
--  step(71,0)
--  right(1)
--  right(71)
--  right(1)
--  rightsector(1, 42, 161)
--  rotright
}

checkerForCell(x, y) {
  -- room for left part of barrels to move over
  stdbox(71,10)
  movestep(0,10)
  set("neighbIx",0)
  forvar("col",0,2,
    !neighbourColumn
    stdbox(10,8)
    movestep(10,0)
    forvar("row",0,2,
      ifelse(and(eq(get("col"),1),eq(get("row"),1)),
        stdbox(22,8) movestep(22,0), -- TODO: place for the blocker
        forvar("neighbCnt",0,3,
	  movestep(0,2)
          linetype(0,checkerLineTag(x,y,get("neighbIx"),get("neighbCnt"))) left(2)
          linetype(0,0) right(1)
	  ifelse(lessthaneq(get("neighbCnt"),2),
            linetype(244,checkerOkLineTag(x,y,get("neighbIx"),get("neighbCnt"))),
            linetype(97,get(cat2("killCell",invNeighbourString(x,y,get("neighbIx")))))
          )
          right(2)
          linetype(0,0) right(1)
          rightsector(0,128,161)
	  turnaround
        )
        movestep(1,-8)
        ifelse(lessthan(get("row"),2),
          stdbox(21,8)
	  movestep(21,0),
          stdbox(16,8) -- just enough to match the box on the left
	  movestep(16,0)
	)
        inc("neighbIx",1)
      )
    )
    if(eq(get("col"),1),
      movestep(-3,1)
      sectortype(0,monsterBlockerTag(x,y))
      ibox(1,56,161,1,6)
      sectortype(0,$scroll_north)
      movestep(-31,3)
      cacodemon
      thingangle(rotatedAngle(angle_west))
    )
    ^neighbourColumn
    movestep(0,8)
    ifelse(lessthan(get("col"),2),
      stdbox(71,19) movestep(0,19),
      stdbox(71,10) movestep(0,10)
    )
  )
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
      set(cat3("monsterBlocker",x,y),newtag)
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
monsterBlockerTag(x,y) {
  get(cat3("monsterBlocker",x,y))
}

stdbox(w,h) {
  box(0,128,161,w,h)
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