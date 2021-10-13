function init_joust_pieces()
  pieces[1].spr_id = 1
  pieces[1].x = 10
  pieces[1].y = 70
  pieces[1].dx = 0
  pieces[13].spr_id = 49 
  pieces[13].x = 120
  pieces[13].y = 70
  pieces[13].alive = false
end

function draw_joust()
  rectfill(0,75,127,127, 3)
  
  spr(game_tbl.clock % 2 > 1 and pieces[1].spr_id or 4, pieces[1].x % 128, pieces[1].y,3,3)
  
  if pieces[13].alive == true then
    spr(game_tbl.clock % 2 == 0 and pieces[13].spr_id or 52, pieces[13].x, pieces[13].y,3,3)
  end

  if(pieces[1].dx == 0 and pieces[13].alive == true) then
    spr(game_tbl.clock % 1 == 0 and 10 or 90, (pieces[1].x % 128) - 5, pieces[1].y - 10, 6, 5)
  end
  game_tbl.clock += 1/4
end

function update_joust()
  pieces[1].x += pieces[1].dx
  pieces[13].x -= pieces[13].dx

  if(btnp(4) and pieces[13].alive == false) then
    pieces[1].dx += 1/12
  end

  if(pieces[1].x > 384 and pieces[13].alive == false) then
    pieces[13].alive = true
    pieces[13].dx =5 
  end

  if((pieces[1].x + 10) % 128 > pieces[13].x and pieces[13].alive == true) then
    pieces[1].dx = 0
    pieces[13].dx = 0
    game_tbl.state = "checkers"
  end
end

