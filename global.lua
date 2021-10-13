total_pieces = 24

pieces = {}
game_tbl = {
  state = "checkers",
  prev_state = "",
  selected = 1,
  paused = false,
  clock = 0
}

function _init()
  palt(14, true)
  palt(0, false)
  for i=1, total_pieces do
    pieces[i] = {
      x = 0,
      y = 0,
      dx = 0,
      dy = 0,
      id = i,
      spr_id = 0,
      alive = true,
      moves = {},
      friction = 0
    }
    if (i<=12) pieces[i].player=1 --player id
    if (i>=13) pieces[i].player=2
  end
end


function _update()
  if game_tbl.state == "joust" then
    if game_tbl.prev_state != "joust" then
      init_joust_pieces()
      game_tbl.prev_state = "joust"
    end
    update_joust()
  elseif game_tbl.state == "checkers" then
    if game_tbl.prev_state != "checkers" then
      make_checkers()
      game_tbl.prev_state = "checkers"
    end
    if making_move == false then 
      check_selected_piece()
    else 
      check_selected_move()
      choose_move()
    end
    update_checkers()
  elseif game_tbl.state == "billiards" then
    if game_tbl.prev_state != "billiards" then
      init_billiards()
      game_tbl.prev_state = "billiards"
    end 
    update_billiards()
  end
end

function _draw()
  cls()
  if game_tbl.state == "joust" then
    draw_joust()
  elseif game_tbl.state == "checkers" then
    map(0,0,32,32,64,64) 
    draw_checkers()
  elseif game_tbl.state == "billiards" then
    draw_billiards()
  end
end