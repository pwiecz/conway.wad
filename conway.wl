#"boom.h"
#"lines.h"
#"monsters.h"
#"spawns.h"
#"standard.h"

wall_texture { "GRAY1" }
blocker_wall_texture { "DOORTRAK" }
floor_texture { "SLIME15" }
step_texture { "FLOOR7_2" }
scroller_texture { "SLIME15" }
playbox_texture { "FLAT5_2" }
dead_cell_texture { "BIGDOOR7" }
alive_cell_texture { "MARBFAC3" }
light_level { 181 }
row_count {13}
col_count {13}
simulator_floor_height { 0 }
simulator_blocker_height { add(simulator_floor_height, 25) }
playbox_floor_height { add(simulator_floor_height,64) }
lowered_step_height { add(playbox_floor_height,9) }
raised_step_height { add(playbox_floor_height,25) }
ceiling_height { add(playbox_floor_height,add(mul(col_count,128),256)) }
/* Dimensions of the area performing the actual simulation
   Everything must be aligned to the blockmap boundaries -
   this way collision detection works reliably. E.g. mancubi are blocking
   all the teleporting lines. */
simulator_x_size { mul(128,row_count) }
-- 320 = 128+128+32+32
simulator_y_size { mul(320,col_count) }
gallery_x_size { 128 }
-- we must fit 7 * row_count * col_count blocks in the control sector
control_sector_y_size { min(div(add(mul(7,mul(row_count,col_count)),1),2),sub(simulator_y_size,1)) }
-- dimensions of the main area where the player can move (not counting the vertical board)
playbox_x_size{ add(mul(row_count,224),128) }
playbox_y_size{ add(mul(col_count,224),500) }
vertical_board_x_size{ mul(128,row_count) }
vertical_board_y_size{ add(mul(8,col_count), 164) }
-- scroll_speed { 34 } -- max speed that works reliably in PrBoom+
-- scroll_speed { 32 } -- max speed that works reliably in GzDoom
scroll_speed { 32 }
barrel { setthing(2035) }
direction_up { 1 }
direction_down { 0 }
raiseceiling { genceiling(trigger_wr,speed_slow,model_numeric,direction_down,ceiling_target_HnC,nochange,0) }
raiseceilingtofloor { genceiling(trigger_wr,speed_slow,model_numeric,direction_down,ceiling_target_HnF,nochange,0) }
lowerceiling { genceiling(trigger_wr,speed_slow,model_numeric,direction_up,ceiling_target_LnC,nochange,0) } -- 16617
raisefloor { genfloor(trigger_wr,speed_slow,model_numeric,direction_down,floor_target_HnF,nochange,0) }-- 24617
raisefloorturbo { genfloor(trigger_wr,speed_turbo,model_numeric,direction_up,floor_target_HnF,nochange,0) } -- 24697
lowerfloor { genfloor(trigger_wr,speed_slow,model_numeric,direction_up,floor_target_LnF,nochange,0) } -- 24809
lowerfloorturbo { genfloor(trigger_wr,speed_turbo,model_numeric,direction_down,floor_target_LnF,nochange,0) }
lowerfloortoceilingturbo {genfloor(trigger_wr,speed_turbo,model_numeric,direction_down,floor_target_LnC,nochange,0) }
lowerfloortoceiling { genfloor(trigger_wr,speed_slow,model_numeric,direction_up,floor_target_LnC,nochange,0) } -- 25057
lowerflooronswitch { genfloor(trigger_s1,speed_slow,model_numeric,direction_up,floor_target_LnF,nochange,0) } -- 24770
lineteleport { 267 }
thingteleport { 269 }

main {
  /* Rotate the map to make it all fit in the positive quarter of the doom coordinate space.
     With the least coordinate at (0,0), this way we can assure that all the simulator blocks
     are aligned to blockmap boundaries.
  */
  turnaround   
  initialize_tags
  floor(floor_texture)
  top("-")
  mid("-")  
  !origin
  draw_external_walls
  xoff(0)
  yoff(0)

  ^origin
  movestep(add(add(simulator_x_size,gallery_x_size),1),0)
  control_sector

  ^gallery_position
  floor(playbox_texture)
  impassable
  unpegged
  mid("MIDBARS3")
  right(simulator_y_size)
  unpegged
  impassable
  mid("-")
  left(gallery_x_size)
  sectortype(0,0)
  leftsector(playbox_floor_height,ceiling_height,light_level)

  -- Close off the simulator sector
  ^playbox_position
  impassable
  unpegged
  mid("MIDBARS3")
  straight(simulator_x_size)
  left(simulator_y_size)
  mid("-")
  unpegged
  impassable
  floor(scroller_texture)
  sectortype(0,$scroll_north)
  leftsector(simulator_floor_height,ceiling_height,light_level)
  set("scrolling_sector",lastsector)
  sectortype(0,0)

  ^origin

  bot(blocker_wall_texture)

  !checkers
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !block
      checker_for_cell(get("x"),get("y"))
      ^block
      movestep(128,0)
    )      
    ^column
    movestep(0,128)
  )
  ^checkers
  movestep(0,mul(128,col_count))

  !alive_cells
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      alive_cell_block(get("x"),get("y"))
      ^cell
      movestep(128,0)
    )
    ^column
    movestep(0,128)
  )
  ^alive_cells  
  movestep(0,mul(128,col_count))

  !ladders
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      check_ladder_for_cell(get("x"),get("y"))
      ^cell
      movestep(70,0)
    )
    ^column
    movestep(0, 32)
  )
  ^ladders
  movestep(sub(simulator_x_size,mul(23,row_count)),0)

  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      board_setter(get("x"),get("y"))
      ^cell
      movestep(23,0)
    )
    ^column
    movestep(0, 32)
  )
  ^ladders
  
  ^ladders
  movestep(0,mul(32,col_count))

  !cells_finished
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      cell_finished_block(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^cells_finished
  movestep(mul(32,row_count),0)

  !wait_nbrs_committed
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      wait_all_nbrs_committed_block(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^wait_nbrs_committed
  movestep(mul(32,row_count),0)

  !wait_nbrs_started
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      wait_all_nbrs_started_block(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^wait_nbrs_started
  movestep(mul(32,row_count),0)

  !barrels
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      !cell
      barrel_start(x,y)
      ^cell
      movestep(32,0)
    )
    ^column
    movestep(0,32)
  )
  ^barrels

  ^playbox_position
  movestep(32, 17)
  player1start
  thingangle(rotated_angle(angle_east))
  movestep(-32, 15)

  yoff(34)
  xoff(47)
  bot("BROWN96")
  right(32)
  left(1)
  xoff(48)
  bot("SW1BROWN")
  linetype(lowerflooronswitch,barrel_start_blocker_tag)
  left(32)
  linetype(0,0)
  xoff(49)
  bot("BROWN96")
  left(1)
  leftsector(add(playbox_floor_height,96),ceiling_height,light_level)
  turnaround
  yoff(0)
  xoff(0)

  -- Close off the playbox sector.
  ^vertical_board_position
  straight(vertical_board_x_size)
  sectortype(0,0)
  floor(playbox_texture)
  leftsector(playbox_floor_height,ceiling_height,light_level)

  ^playbox_position

  movestep(128, 128)
  bot("MARBGRAY")
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      forcesector(step_on_sector(x,y))
      linetype(lowerfloortoceiling,set_cell_tag(x,y))--cell_dead_blocker_tag(x,y))
      ibox(0,0,0,128,128)
      popsector
      movestep(224,0)
    )
    ^column
    movestep(0,224)
  )
  linetype(0,0)

  ^vertical_board_position
  forvar("y",0,sub(row_count,1),
    bot(alive_cell_texture)
    riserstep(y,playbox_floor_height,0,alive_cell_texture)
    movestep(128,0)
  )
  ^vertical_board_position
  movestep(0,4)
  forvar("x",0,sub(col_count,1),
    !column
    forvar("y",0,sub(row_count,1),
      riserstep(y,add(playbox_floor_height,mul(x,128)),cell_killed_blocker_tag(x,y),dead_cell_texture)
      movestep(0,4)
      riserstep(y,add(playbox_floor_height,mul(add(x,1),128)),0,alive_cell_texture)
      movestep(128,-4)
    )
    ^column
    movestep(0,8)
  )

  linetype(exit_w1_normal,0)
  box(add(playbox_floor_height,mul(128,col_count)),ceiling_height,light_level,vertical_board_x_size, 32)
  movestep(0,32)
  floor("F_SKY1")
  box(add(playbox_floor_height,sub(mul(col_count,128),16)),ceiling_height,light_level,vertical_board_x_size,128)
}

/*
 * Draw external walls and record positions of bottom-left corners of various subsectors.
 * All the things and lines will be placed inside those walls
 * Don't create any sector.
 * This draws all the lindefs with opaque midtexture and let's us use empty midtexture
 * for all the remaining linedefs, which helps ameliorate problems with midtexture bleeding.
 * Reset midtexture and orientation before saving any state, so that we don't have to reset
 * them elsewhere in the code.
*/ 
draw_external_walls() {
  undefx
  mid(wall_texture)
  linetype(252, $scroll_north) straight(scroll_speed)
  linetype(0,0) straight(sub(simulator_x_size, scroll_speed))
  mid("-")
  !gallery_position
  mid(wall_texture)
  straight(gallery_x_size)
  right(simulator_y_size)
  left(sub(playbox_x_size, add(simulator_x_size,gallery_x_size)))
  right(playbox_y_size)
  right(sub(playbox_x_size,vertical_board_x_size))
  left(vertical_board_y_size)
  right(vertical_board_x_size)
  right(vertical_board_y_size)
  rotright mid("-")
  !vertical_board_position
  mid(wall_texture)
  left(playbox_y_size)
  rotright mid("-")
  !playbox_position
  mid(wall_texture)
  left(simulator_y_size)
  rotright
}

riserstep(y,floor,tag,tex) {
  bot(tex)
  straight(128)
  bot("MARBLE1")
  right(4)
  bot(tex)
  right(128)
  bot("MARBLE1")
  right(4)
  sectortype(0,tag)
  rightsector(floor,ceiling_height,light_level)
  sectortype(0,0)
  rotright
}

maybe_next_control_row() {
  if(lessthaneq(control_sector_y_size,get("control_y_pos")),
    ^row
    set("control_y_pos",0)
    movestep(1,0)
    inc("control_row_count",1)
    if(eq(mod(get("control_row_count"),2),0),
      forcesector(get("raised_sector"))
      box(0,0,1,control_sector_y_size)
      movestep(1,0))
      !row)
}

/* 
 * Make a "raised_sector" with high floor neighbour all of the sectors used for blocking
 * barrel and mancubus movements. So that we can instantly move them up and down.
 * Also contains "low_ceiling_sector" used for lowering "step_on_sector" to a low (but not zero)
 * position using move-floor-to-lowest-neighbour-ceiling action.
 * Also contains sectors for controlling setting up the board and disabling the set-up function
 * once the simulation start.
 */
control_sector() {
  sectortype(0,0)
  box(simulator_blocker_height,ceiling_height,light_level,1,control_sector_y_size)
  set("raised_sector",lastsector)
  movestep(1,0)
  set("control_y_pos",0)
  set("control_row_count",0)
  !row
  forvar("y",0,sub(row_count,1),
    forvar("x",0,sub(col_count,1),
      maybe_next_control_row
      sectortype(0,cell_dead_blocker_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("cell_dead_blocker_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
      maybe_next_control_row
      sectortype(0,cell_alive_blocker_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("cell_alive_blocker_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
      maybe_next_control_row
      sectortype(0,cell_killed_blocker_tag(x,y))
      box(simulator_floor_height,ceiling_height,light_level,1,1)
      set(cat3("cell_killed_blocker_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
      maybe_next_control_row
      sectortype(0,cell_revived_blocker_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("cell_revived_blocker_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
      maybe_next_control_row
      sectortype(0,cell_finished_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("cell_finished_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
      maybe_next_control_row
      sectortype(0,cell_committed_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("cell_committed_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
      maybe_next_control_row
      sectortype(0,cell_started_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("cell_started_sector",x,y),lastsector)
      movestep(0,1)
      inc("control_y_pos",1)
    )
  )
  sectortype(0,0)
  inc("control_row_count",1)
  if(eq(mod(get("control_row_count"),2),0),
    ^row
    movestep(1,0)
    forcesector(get("raised_sector"))
    box(0,0,0,1,control_sector_y_size)
    !row
  )

  ^row
  movestep(1,0)

  -- A sector with ceiling at the height of the lowered board step, used as a target
  -- for lowering it down
  box(playbox_floor_height,lowered_step_height,light_level,1,mul(row_count,col_count))
  movestep(1,0)
  !row
  floor(step_texture)
  forvar("y",0,sub(row_count,1),
    forvar("x",0,sub(col_count,1),
      sectortype(0,step_tag(x,y))
      box(lowered_step_height,ceiling_height,light_level,1,1)
      set(cat3("step_on_sector",x,y),lastsector)
      movestep(0,1)
    )
  )
  ^row
  movestep(1,0)

  sectortype(0,0)
  box(raised_step_height,ceiling_height,light_level,1,mul(row_count,col_count))
  movestep(1,0)
  box(simulator_blocker_height,ceiling_height,light_level,1,mul(row_count,col_count))
  movestep(1,0)
  sectortype(0,setter_control_tag)
  box(simulator_floor_height,simulator_floor_height,light_level,1,mul(row_count,col_count))
  movestep(1,0)
  forvar("y",0,sub(row_count,1),
    forvar("x",0,sub(col_count,1),
      sectortype(0,set_cell_tag(x,y))
      box(simulator_blocker_height,ceiling_height,light_level,1,1)
      set(cat3("set_cell_sector",x,y),lastsector)
      movestep(0,1)
    )
  )
  sectortype(0,0)
}

/*
 * Generate series of teleport lines that performs actual counting of alive neighbours
 * of a given cell using a barrel that's being pushed through them.
 * Consists of 4 groups of teleport lines:
 * - one when we've found so far 0 alive cells among neighbours
 * - one when we've found so far 1 alive cell among neighbours
 * - one when we've found so far 2 alive cells among neighbours
 * - one when we've found so far 3 alive cells among neighbours
 * If we find any alive neighbours using line in one group, the barrel gets teleported
 * to an appropriate place in the following group to search through remaining neighbours.
 * If we reach end of the group it means we have in total 0,1,2 or 3 alive neighbours,
 * and our cell should be killed, kept in the same state or made alive.
 */
check_ladder_for_cell(x, y) {
  movestep(10,6)
  lineleft(20,0,start_check_tag(x,y))
  fori(0, 6,
    check_ladder_step(x, y, i, 0)
  )
  movestep(1,0)
  lineright(20,thingteleport,kill_cell_tag(x,y))

  fori(1,7,
    check_ladder_step(x, y, i, 1)
  )
  movestep(1,0)
  lineright(20,thingteleport,kill_cell_tag(x,y))

  fori(2,7,
    check_ladder_step(x, y, i, 2)
  )
  movestep(1,0)
  lineright(20,thingteleport,keep_cell_tag(x,y))

  fori(3,7,
    check_ladder_step(x, y, i, 3)
  )
  movestep(1,0)
  lineright(20,thingteleport,revive_cell_tag(x,y))
}

check_ladder_step(x, y, nbr_ix, nbrCnt) {
  if(lessthaneq(1,nbrCnt),
    movestep(1,0)
    lineleft(20,0,checkee_ok_line_tag(x,y,sub(nbr_ix,1),sub(nbrCnt,1)))
  )
  movestep(1,0)
  lineright(20,lineteleport,checkee_line_tag(x,y,nbr_ix,nbrCnt))
}

board_setter(x,y) {
  movestep(10,16)
  barrel
  thing
  movestep(10,-10)
  forcesector(set_cell_sector(x,y))
  ibox(simulator_blocker_height,ceiling_height,light_level,1,20)
  popsector
  movestep(-9,0)
  lineright(20,lowerfloor,cell_dead_blocker_tag(x,y))
  movestep(11,0)
}

/*
 * Create a block with series of teleport lines for a barrel to potentially move through.
 * Those lines will be blocked by a mancubus if corresponding cell is not alive.
 * If the cell is alive a barrel will arrive via a line corresponding to a situation:
 * "we are the n-th neighbour of cell, which has so far found k alive neighbours" and it will
 * be teleported back to a line corresponding to a situation "the cell has k+1 alive neighbours
 * among its first n neighbours". If we can already decide what should be the fate of
 * the cell in the next round (because we're the last neighbour being processed, or we are already
 * 4th alive neighbour), we can send the barrel to the corresponding position in the cell_finished
 * block.
 */
checker_for_cell(x, y) {
  movestep(0,14)
  set("nbr_ix",0)
  !nbrs
  -- create two columns of teleporter lines on two sides of the area occupied by the mancubus
  -- when the cell is dead.
  forvar("col",0,1,
    !nbrColumn
    forvar("row",0,3,
      movestep(10,0)
      lineleft(2,0,checker_line_tag(x,y,get("nbr_ix"),0))
      movestep(1,0)
      ifelse(eq(get("nbr_ix"),7),
        lineright(2,thingteleport,get(cat2("kill_cell",inv_nbr_string(x,y,get("nbr_ix"))))),
        lineright(2,lineteleport,checker_ok_line_tag(x,y,get("nbr_ix"),0))
      )
      movestep(1,0)
      lineleft(2,0,checker_line_tag(x,y,get("nbr_ix"),1))
      movestep(1,0)
      ifelse(eq(get("nbr_ix"),7),
        lineright(2,thingteleport,get(cat2("keep_cell",inv_nbr_string(x,y,get("nbr_ix"))))),
        lineright(2,lineteleport,checker_ok_line_tag(x,y,get("nbr_ix"),1))
      )
      movestep(1,0)
      lineleft(2,0,checker_line_tag(x,y,get("nbr_ix"),2))
      movestep(1,0)
      ifelse(eq(get("nbr_ix"),7),
        lineright(2,thingteleport,get(cat2("revive_cell",inv_nbr_string(x,y,get("nbr_ix"))))),
        lineright(2,lineteleport,checker_ok_line_tag(x,y,get("nbr_ix"),2))
      )
      movestep(1,0)
      lineleft(2,0,checker_line_tag(x,y,get("nbr_ix"),3))
      movestep(1,0)
      lineright(2,thingteleport,get(cat2("kill_cell",inv_nbr_string(x,y,get("nbr_ix")))))
      movestep(11,0)
      inc("nbr_ix",1)
    )
    ^nbrColumn
    movestep(0,98)
  )
  ^nbrs
  movestep(56,50)
  mancubus
  thingangle(rotated_angle(angle_north))
  movestep(-4,-10)
  lineleft(20,0,cell_dead_tag(x,y))
  movestep(1,0)
  lineright(20,lowerfloortoceilingturbo,step_tag(x,y))
  movestep(1,0)
  lineright(20,raisefloor,cell_revived_blocker_tag(x,y))
  movestep(1,0)
  lineright(20,lowerfloor,cell_killed_blocker_tag(x,y))
  movestep(2,0)
  lineright(20,raisefloor,cell_alive_blocker_tag(x,y))
  movestep(1,0)
  lineright(20,lineteleport,cell_alive_tag(x,y))
  movestep(46,0)
  forcesector(cell_dead_blocker_sector(x,y))
  ibox(0,0,0,1,20)
  popsector
}

/*
 * Create a block where mancubus will be placed when the corresponding cell is alive.
 * In that case it does not block any teleporter lines for a barrel.
 */
alive_cell_block(x,y) {
  sectortype(0,0)
  movestep(48,16)
  lineleft(96,0,cell_alive_tag(x,y))
  movestep(1,0)
  lineright(96,raisefloorturbo,step_tag(x,y))
  movestep(1,0)
  lineright(96,raisefloor,cell_killed_blocker_tag(x,y))
  movestep(1,0)
  lineright(96,lowerfloor,cell_revived_blocker_tag(x,y))
  movestep(2,0)
  lineright(96,raisefloor,cell_dead_blocker_tag(x,y))
  movestep(1,0)
  lineright(96,lineteleport,cell_dead_tag(x,y))
  movestep(46,0)
  forcesector(cell_alive_blocker_sector(x,y))
  ibox(0,0,0,1,96)
  popsector
}

/*
 * A block being a start position for a barrel before the user pulls the switch
 * to start the simulation.
 */
barrel_start(x,y) {
  movestep(10,16)
  barrel
  thing
  movestep(1,-10)
  -- Raise ceiling next to the blockers of barrels used for initial board setup, so that after
  -- the start walking over the board will have no effect.
  if(and(eq(x,0),eq(y,0)),
    lineright(20,raiseceilingtofloor,setter_control_tag))
  movestep(1,0)
  lineright(20,thingteleport,keep_cell_tag(x,y))
  movestep(8,0)
  sectortype(0,barrel_start_blocker_tag)
  if(or(lessthan(0,x),lessthan(0,y)),forcesector(get("barrel_start_blocker_sector")))
  ibox(simulator_blocker_height,ceiling_height,light_level,1,20)
  if(and(eq(x,0),eq(y,0)),set("barrel_start_blocker_sector",lastsector))
  sectortype(0,0)
  popsector
}

/*
 * Barrel will be teleported to this block once it has counted alive neighbours of its cell,
 * and the fate of the cell is known. The barrel will be teleported into one of the three
 * positions corresponding to the cell being about to be killed, revived or kept in the same state.
 * First it will wait for all its neighbours to also finish counting its neighbours.
 * Then depending on the position where it gets teleported to, it will unlock mancubus movement
 * allowing it to teleport to its "cell dead"/"cell alive" position.
 * Then it will wail for the mancubus to reach its new position, and finally the barrel will be
 * teleported to the "all_neighbours_finished" position.
 */
cell_finished_block(x, y) {
  movestep(9,10)
  sectortype(0,kill_cell_tag(x,y))
  teleport_sector_with_front_line(2,2,raisefloor,cell_committed_tag(x,y))
  movestep(0,2)
  sectortype(0,keep_cell_tag(x,y))
  teleport_sector_with_front_line(2,8,lowerfloor,cell_finished_tag(x,y))
  movestep(0,8)
  sectortype(0,revive_cell_tag(x,y))
  teleport_sector_with_front_line(2,2,raisefloor,cell_committed_tag(x,y))
  sectortype(0,0)
  movestep(0,-10)
  forcesector(get("scrolling_sector"))
  invbox(0,0,0,2,12)
  movestep(13,2)
  !all_finished
  forvar("nbr_ix",0,7,
    forcesector(cell_nbr_finished_sector(x,y,get("nbr_ix")))
    xoff(mod(get("nbr_ix"),2))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^all_finished
  forcesector(get("scrolling_sector"))
  invbox(0,0,0,1,8)
  xoff(0)
  movestep(-9,-11)
  
  lineright(2,raisefloor,cell_dead_blocker_tag(x,y))
  movestep(1,0)
  lineright(2,lowerfloor,cell_alive_blocker_tag(x,y))
  movestep(11,0)
  forcesector(cell_killed_blocker_sector(x,y))
  ibox(0,0,0,1,2)
  popsector
  movestep(-12,28)
  lineright(2,raisefloor,cell_alive_blocker_tag(x,y))
  movestep(1,0)
  lineright(2,lowerfloor,cell_dead_blocker_tag(x,y))
  movestep(11,0)
  forcesector(cell_revived_blocker_sector(x,y))
  ibox(0,0,0,1,2)
  popsector
  movestep(-9,-23)
  lineright(20,lineteleport,all_nbrs_finished_tag(x,y))
}

/*
 * Two following functions create blocks used for synchronization of movement between
 * neighbouring barrels.
 */
wait_all_nbrs_committed_block(x,y) {
  movestep(10, 6)
  lineleft(20,0,all_nbrs_finished_tag(x,y))
  movestep(1,0)
  lineright(20,raisefloor,cell_started_tag(x,y))
  movestep(1,0)
  lineright(20,lowerfloor,cell_committed_tag(x,y))
  movestep(11,6)
  !all_committed
  forvar("nbr_ix",0,7,
    forcesector(cell_nbr_committed_sector(x,y,get("nbr_ix")))
    xoff(mod(get("nbr_ix"),2))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^all_committed
  forcesector(get("scrolling_sector"))
  invbox(0,0,0,1,8)
  xoff(0)
  movestep(-9,-6)

  lineright(20,lineteleport,all_nbrs_committed_tag(x,y))
}

wait_all_nbrs_started_block(x,y) {
  movestep(10, 6)
  lineleft(20,0,all_nbrs_committed_tag(x,y))
  movestep(1,0)
  lineright(20,raisefloor,cell_finished_tag(x,y))
  movestep(1,0)
  lineright(20,lowerfloor,cell_started_tag(x,y))
  movestep(11,6)
  !all_started
  forvar("nbr_ix",0,7,
    forcesector(cell_nbr_started_sector(x,y,get("nbr_ix")))
    xoff(mod(get("nbr_ix"),2))
    box(0,0,0,1,1)
    movestep(0,1)
  )
  ^all_started
  forcesector(get("scrolling_sector"))
  invbox(0,0,0,1,8)
  xoff(0)
  movestep(-9,-6)

  lineright(20,lineteleport,start_check_tag(x,y))
}

/*
 * Create a disconnected linedef with given length, type and tag.
 * Use empty textures for disconnected linedefs, so that ZokumBSP can recognize those
 * linedefs as invisible and ignore them in bsp calculations.
*/
lineright(len,type,tag) {
  !line_start_position
  bot("-")
  forcesector(get("scrolling_sector"))
  linetype(type,tag) step(0,len)
  linetype(0,0) step(0,neg(len))
  rightsector(0,0,0)
  ^line_start_position
}
/*
 * Create a disconnected linedef with inversed orientation.
 * Used for creating a destination line for line-to-line teleporters.
 */
lineleft(len,type,tag) {
  !line_start_position
  bot("-")
  forcesector(get("scrolling_sector"))
  movestep(0,len)
  linetype(type,tag) step(0,neg(len))
  linetype(0,0) step(0,len)
  rightsector(0,0,0)
  ^line_start_position
}

/*
 * Draw a rectangular sector with a teleport landing in the middle.
 * Make the front line of the sector have specified type and tag.
 */
teleport_sector_with_front_line(x,y,line_type,line_tag) {
  linetype(0,0) straight(x)
  linetype(line_type,line_tag) right(y)
  linetype(0,0) right(x)
  right(y)
  rightsector(simulator_floor_height,ceiling_height,light_level)
  rotright
  movestep(div(x,2),div(y,2))
  teleportlanding
  thingangle(rotated_angle(angle_north))
  movestep(div(x,-2),div(y,-2))
}

/*
 * Generate string in format "X,Y" where X and Y are coordinates of neighbour cell of x and y.
 * nbr_ix is the index of the neighbours - 0 being bottom-left, and 7 being top-right.
 */
nbr_string(x, y, nbr_ix) {
  ifelse(eq(nbr_ix,0),
    cat2(subx1(x),suby1(y)),
    ifelse(eq(nbr_ix,1),
      cat2(subx1(x),y),
      ifelse(eq(nbr_ix,2),
        cat2(subx1(x),addy1(y)),
	ifelse(eq(nbr_ix,3),
          cat2(x,suby1(y)),
	  ifelse(eq(nbr_ix,4),
            cat2(x,addy1(y)),
	    ifelse(eq(nbr_ix,5),
              cat2(addx1(x),suby1(y)),
	      ifelse(eq(nbr_ix,6),
                cat2(addx1(x),y),
		cat2(addx1(x),addy1(y)))))))))
}
inv_nbr_string(x, y, nbr_ix) {
  nbr_string(x,y,sub(7,nbr_ix))
}
subx1(x) {
  mod(add(x,sub(col_count,1)),col_count)
}
addx1(x) {
  mod(add(x,1),col_count)
}
suby1(y) {
  mod(add(y,sub(row_count,1)),row_count)
}
addy1(y) {
  mod(add(y,1),row_count)
}

initialize_tags {
  set("barrel_start_blocker",newtag)
  set("raised_sector_tag",newtag)
  set("setter_control_tag",newtag)
  forvar("x",0,sub(col_count,1),
    forvar("y",0,sub(row_count,1),
      set(cat3("kill_cell",x,y),newtag)
      set(cat3("keep_cell",x,y),newtag)
      set(cat3("revive_cell",x,y),newtag)
      set(cat3("cell_dead",x,y),newtag)
      set(cat3("cell_dead_blocker",x,y),newtag)
      set(cat3("cell_killed_blocker",x,y),newtag)
      set(cat3("cell_alive",x,y),newtag)
      set(cat3("cell_alive_blocker",x,y),newtag)
      set(cat3("cell_revived_blocker",x,y),newtag)
      set(cat3("cell_finished",x,y),newtag)
      set(cat3("cell_started",x,y),newtag)
      set(cat3("cell_committed",x,y),newtag)
      set(cat3("start_check",x,y),newtag)
      set(cat3("all_nbrs_finished",x,y),newtag)
      set(cat3("all_nbrs_committed",x,y),newtag)
      set(cat3("step",x,y),newtag)
      set(cat3("set_cell",x,y),newtag)
      forvar("nbr_ix",0,7,
        forvar("nbr_count",0,3,
          set(cat5("check",get("x"),get("y"),get("nbr_ix"),get("nbr_count")),newtag)
          if(and(lessthan(get("nbr_count"),3),lessthan(get("nbr_ix"),7)),
            set(cat5("check_ok",get("x"),get("y"),get("nbr_ix"),get("nbr_count")),newtag))
        )
      )
    )
  )
}

barrel_start_blocker_tag {
  get("barrel_start_blocker")
}
raised_sector_tag {
  get("raised_sector_tag")
}
setter_control_tag {
  get("setter_control_tag")
}
checkee_line_tag(x,y,nbr_ix,nbr_count) {
  get(cat4("check",nbr_string(x,y,nbr_ix),nbr_ix,nbr_count))
}
checkee_ok_line_tag(x,y,nbr_ix,nbr_count) {
  get(cat4("check_ok",nbr_string(x,y,nbr_ix),nbr_ix,nbr_count))
}
checker_line_tag(x,y,nbr_ix,nbr_count) {
  get(cat5("check",x,y,nbr_ix,nbr_count))
}
checker_ok_line_tag(x,y,nbr_ix,nbr_count) {
  get(cat5("check_ok",x,y,nbr_ix,nbr_count))
}
kill_cell_tag(x,y) {
  get(cat3("kill_cell",x,y))
}
keep_cell_tag(x,y) {
  get(cat3("keep_cell",x,y))
}
revive_cell_tag(x,y) {
  get(cat3("revive_cell",x,y))
}
cell_dead_tag(x,y) {
  get(cat3("cell_dead",x,y))
}
cell_dead_blocker_tag(x,y) {
  get(cat3("cell_dead_blocker",x,y))
}
cell_killed_blocker_tag(x,y) {
  get(cat3("cell_killed_blocker",x,y))
}
cell_alive_tag(x,y) {
  get(cat3("cell_alive",x,y))
}
cell_alive_blocker_tag(x,y) {
  get(cat3("cell_alive_blocker",x,y))
}
cell_revived_blocker_tag(x,y) {
  get(cat3("cell_revived_blocker",x,y))
}
start_check_tag(x,y) {
  get(cat3("start_check",x,y))
}
all_nbrs_finished_tag(x,y) {
  get(cat3("all_nbrs_finished",x,y))
}
all_nbrs_committed_tag(x,y) {
  get(cat3("all_nbrs_committed",x,y))
}
cell_finished_tag(x,y) {
  get(cat3("cell_finished",x,y))
}
cell_committed_tag(x,y) {
  get(cat3("cell_committed",x,y))
}
cell_started_tag(x,y) {
  get(cat3("cell_started",x,y))
}
cell_nbr_finished_sector(x,y,nbr_ix) {
  get(cat2("cell_finished_sector",nbr_string(x,y,nbr_ix)))
}
cell_nbr_committed_sector(x,y,nbr_ix) {
  get(cat2("cell_committed_sector",nbr_string(x,y,nbr_ix)))
}
cell_nbr_started_sector(x,y,nbr_ix) {
  get(cat2("cell_started_sector",nbr_string(x,y,nbr_ix)))
}
cell_alive_blocker_sector(x,y) {
  get(cat3("cell_alive_blocker_sector",x,y))
}
cell_revived_blocker_sector(x,y) {
  get(cat3("cell_revived_blocker_sector",x,y))
}
cell_dead_blocker_sector(x,y) {
  get(cat3("cell_dead_blocker_sector",x,y))
}
cell_killed_blocker_sector(x,y) {
  get(cat3("cell_killed_blocker_sector",x,y))
}
step_tag(x,y) {
  get(cat3("step",x,y))
}
step_on_sector(x,y) {
  get(cat3("step_on_sector",x,y))
}
set_cell_tag(x,y) {
  get(cat3("set_cell",x,y))
}
set_cell_sector(x,y) {
  get(cat3("set_cell_sector",x,y))
}
stdiboxwithfrontline(x,y,type,tag) {
  linetype(0,0) straight(x)
  linetype(type,tag) right(y)
  linetype(0,0) right(x)
  right(y)
  innerrightsector(simulator_floor_height,ceiling_height,light_level)
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
min(a,b) {
  ifelse(lessthaneq(a,b),a,b)
}
rotated_angle(angle) {
  ifelse(eq(getorient,0),
    angle,
    ifelse(eq(getorient,1),
      mod(add(angle,270),360),
      ifelse(eq(getorient,2),
        mod(add(angle,180),360),
	mod(add(angle,90),360))))

}
