#"standard.h"
#"spawns.h"

rowCount {10}
colCount {10}

main {
  !init
  movestep(-100, -102)
  straight(32) linetype(0,0) right(1) 
  linetype(253, $scroll_north) right(32)
  right(1)
  leftsector(0,0,0)
  rotright
  ^init
  
--  mergesectors
  initializeLineTags  

  sectortype(0, $scroll_north)

  forvar("x",0,sub(rowCount,1),
    !column
    forvar("y",0,sub(colCount,1),
      !ladder
      checkLadderForCell(get("x"),get("y"))
      ^ladder
      movestep(0, 20)
      checkerForCell(get("x"),get("y"))
      ^ladder
      movestep(71, 0)
    )
    ^column
    movestep(0, 102)
  )

  sectortype(0,0)
  stdbox(1000, 1000)
  movestep(32, 32)

  player1start
  thing
}

checkLadderStepZeroNeighbs(x, y, neighbIx) {
  step(1, 0)
  linetype(244, checkeeLineTag(x,y,neighbIx,0)) right(20)
  linetype(0, 0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)
}
checkLadderStepNonZeroNeighbs(x, y, neighbIx, neighbCnt) {
  step(1, 0)
  linetype(0, checkeeOkLineTag(x,y,sub(neighbIx,1),sub(neighbCnt,1))) right(20)
  linetype(0, 0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright

  movestep(1, 0)
  step(1, 0)
  linetype(244, checkeeLineTag(x,y,neighbIx,neighbCnt)) right(20)
  linetype(0, 0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright

  movestep(1, 0)
}

checkLadderForCell(x, y) {
  -- place for the back half of the barrel
  stdbox(10, 20)
  movestep(10,0)
  movestep(0,10)
  -- barrel
  setthing(2035)
  thing
  movestep(0,-10)
  fori(0, 6, 
    checkLadderStepZeroNeighbs(x, y, i)
  )
  step(1, 0)
  linetype(244,killCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)

  -- headroom to make the barrel fit before the blocker
  stdbox(2,20)
  movestep(2,0)
  
  sectortype(0,$blocker)
  box(1, 42, 160, 1, 20)
  sectortype(0, $scroll_north)

  movestep(1, 0)

  fori(1,7,
    checkLadderStepNonZeroNeighbs(x, y, i, 1)
  )
  step(1, 0)
  linetype(244,killCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)

  fori(2,7,
    checkLadderStepNonZeroNeighbs(x, y, i, 2))
  step(1, 0)
  linetype(97,keepCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)

  fori(3,7,
    checkLadderStepNonZeroNeighbs(x, y, i, 3))
  step(1, 0)
  linetype(97,reviveCellTag(x,y)) right(20)
  linetype(0,0) right(1)
  right(20)
  rightsector(0, 128, 161)
  rotright
  movestep(1, 0)
  --headroom for front of the barrel
  stdbox(11, 20)
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
          linetype(244,checkerOkLineTag(x,y,get("neighbIx"),get("neighbCnt"))) right(2)
          linetype(0,0) right(1)
          rightsector(0,128,160)
	  turnaround
        )
        movestep(1,-8)
        ifelse(lessthan(get("row"),2),
          stdbox(21,8),
          stdbox(16,8) -- just enough to match the box on the left
	)
        movestep(21,0)
        inc("neighbIx",1)
      )
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
      set(cat3("killCell",x,y),newtag)
      set(cat3("keepCell",x,y),newtag)
      set(cat3("reviveCell",x,y),newtag)
      forvar("neighbIx",0,7,
        forvar("neighbCnt",0,3,
          set(cat5("check",get("x"),get("y"),get("neighbIx"),get("neighbCnt")),newtag)
          set(cat5("checkOk",get("x"),get("y"),get("neighbIx"),get("neighbCnt")),newtag)
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
killCellTag(x,y) {
  get(cat3("killCell",x,y))
}
keepCellTag(x,y) {
  get(cat3("keepCell",x,y))
}
reviveCellTag(x,y) {
  get(cat3("reviveCell",x,y))
}

stdbox(w,h) {
  box(0,128,160,w,h)
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
