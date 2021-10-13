function make_checkers() 
  jumpers = {}
  making_move = false
  move_num = 0
  comp_piece = {}
  game_tbl.selected = 12
  player_turn = 1
  --init red checkers player 1
  for i=1,24,1 do
    piece=pieces[i]
    if(piece.alive) then 
      --player 1's tiles
      if piece.player == 1 then 
        piece.player = 2 -- this handles making pieces 1-12 player two - the computers pieces
        if 5<=i and i<=8 then
          piece.x = (2*i-2)%8
          piece.y = 1
        else
          piece.x = (2*i-1)%8
          if (i<=4) piece.y = 0
          if (i>=9) piece.y = 2
        end
        piece.spr_id=97 --set sprite
    --in
      elseif piece.player == 2 then
        piece.player = 1 --and this handles giving player 1, the player, 13-24
        if 17<=i and i<=20 then
          piece.x = (2*i-2)%8+1
          piece.y = 6
        else
          piece.x = (2*i-1)%8-1
          if (i<=16) piece.y = 5
          if (i>=21) piece.y = 7
        end
        piece.spr_id=98 --set sprite
      end
    end
  end
end

function draw_checkers()
  if(player_turn==1) spr(99, pieces[game_tbl.selected].x*8+32, pieces[game_tbl.selected].y*8+32) --draw cursor
  if(#pieces[game_tbl.selected].moves>0) draw_moves()
  
end
--updates player's selection of piece
function check_selected_piece()
  if(player_turn==1) then
    if(btnp(0)) then
      game_tbl.selected-=1
      if(game_tbl.selected<13) game_tbl.selected=24
      while(pieces[game_tbl.selected].alive == false) do 
        game_tbl.selected-=1
        if(game_tbl.selected<13) game_tbl.selected=24
      end
      check_all_moves()
    end
    if(btnp(1)) then
      game_tbl.selected+=1 
      if(game_tbl.selected>24) game_tbl.selected=13
      while(pieces[game_tbl.selected].alive == false) do 
        game_tbl.selected+=1 
        if(game_tbl.selected>24) game_tbl.selected=13
      end
      check_all_moves()
    end
  end
  choose_move()
end


function check_all_moves()
  jumpers = {} --empty out the jumpers
  for i=1,24 do --empty out moves list
    pieces[i].moves = {}
  end
  --red jumps
  if player_turn == 2 then --computer check
    for i=1,12 do
      if(pieces[i].alive) then
        --right jump
        if(mget(pieces[i].x+1,pieces[i].y+1)==98 and mget(pieces[i].x+2,pieces[i].y+2)==96) then
          add(jumpers, pieces[i].id)
          add(pieces[i].moves, 2)
        end
        --left jump
        if(mget(pieces[i].x-1,pieces[i].y+1)==98 and mget(pieces[i].x-2,pieces[i].y+2)==96) then
          add(jumpers, pieces[i].id)
          add(pieces[i].moves, -2)
        end
      end
    end
  else --black jumps
    for i=13,24 do
      if(pieces[i].alive) then
        --right jump
        if(mget(pieces[i].x+1,pieces[i].y-1)==97 and mget(pieces[i].x+2,pieces[i].y-2)==96) then
          add(jumpers, pieces[i].id)
          add(pieces[i].moves, 2)
        end
        --left jump
        if(mget(pieces[i].x-1,pieces[i].y-1)==97 and mget(pieces[i].x-2,pieces[i].y-2)==96) then
          add(jumpers, pieces[i].id)
          add(pieces[i].moves, -2)
        end
      end
    end
  end

  if #jumpers > 0 then --if there are jumpers
    can_move = false
    if (contains(jumpers, game_tbl.selected)) can_move=true
  else
  --IF THERE ARE NO JUMPERS YOU CAN MOVE NORMALLY
    if(player_turn ~= 1) then --computer std moves
      for i=1, 12 do 
        if(pieces[i].alive) then
          if(mget(pieces[i].x+1,pieces[i].y+1)==96) add(pieces[i].moves, 1)
          if(mget(pieces[i].x-1,pieces[i].y+1)==96) add(pieces[i].moves, -1)
        end
      end
    else--player std moves
      for i=13,24 do
        if(pieces[i].alive) then
          if(mget(pieces[i].x+1,pieces[i].y-1)==96) add(pieces[i].moves, 1) --to the right
          if(mget(pieces[i].x-1,pieces[i].y-1)==96) add(pieces[i].moves, -1) --to the left
        end
      end
    end
  end
end

function draw_moves() -- only matters for player
  if(player_turn == 1) then --black
    if(#jumpers>0)then
      if(contains(pieces[game_tbl.selected].moves,2)) then
        spr(115, pieces[game_tbl.selected].x*8+48, pieces[game_tbl.selected].y*8+16)
      end
      if(contains(pieces[game_tbl.selected].moves,-2)) then
        spr(115, pieces[game_tbl.selected].x*8+16,pieces[game_tbl.selected].y*8+16)
      end
    else
      if(contains(pieces[game_tbl.selected].moves,1)) then
        spr(115, pieces[game_tbl.selected].x*8+40,pieces[game_tbl.selected].y*8+24)
      end
      if(contains(pieces[game_tbl.selected].moves,-1)) then
        spr(115, pieces[game_tbl.selected].x*8+24,pieces[game_tbl.selected].y*8+24)
      end
    end

    if(making_move) then --draw selector
      if(move_selectx==2) then
        spr(0, pieces[game_tbl.selected].x*8+48, pieces[game_tbl.selected].y*8+16)
      elseif(move_selectx==1) then
        spr(0, pieces[game_tbl.selected].x*8+40,pieces[game_tbl.selected].y*8+24)
      elseif(move_selectx==-1)then
        spr(0, pieces[game_tbl.selected].x*8+24,pieces[game_tbl.selected].y*8+24)
      elseif(move_selectx==-2)then
        spr(0, pieces[game_tbl.selected].x*8+16,pieces[game_tbl.selected].y*8+16)
      end
    end
  end
end


function choose_move() --player based
  if(player_turn == 1) then
    if(btnp(4) and making_move and move_selectx ~= 0) then --actually makes the move
      making_move = false
      mset(pieces[game_tbl.selected].x, pieces[game_tbl.selected].y, 96)
      if(move_selectx==2) then
        mset(pieces[game_tbl.selected].x+1, pieces[game_tbl.selected].y-1, 96)
        for i=1,12 do
          if(pieces[i].x == pieces[game_tbl.selected].x+1 and pieces[i].y == pieces[game_tbl.selected].y-1) pieces[i].alive = false
        end
        pieces[game_tbl.selected].x+=2
        pieces[game_tbl.selected].y-=2
      elseif(move_selectx==-2) then
        mset(pieces[game_tbl.selected].x-1, pieces[game_tbl.selected].y-1, 96)
        for i=1,12 do
          if(pieces[i].x == pieces[game_tbl.selected].x-1 and pieces[i].y == pieces[game_tbl.selected].y-1) pieces[i].alive = false
        end
        pieces[game_tbl.selected].x -= 2
        pieces[game_tbl.selected].y -= 2
      elseif(move_selectx==1) then
        pieces[game_tbl.selected].x+=1
        pieces[game_tbl.selected].y-=1
      elseif(move_selectx==-1) then
        pieces[game_tbl.selected].x-=1
        pieces[game_tbl.selected].y-=1
      end
      check_king()
      update_checkers()
      computer_turn()
    end
    if(btnp(4) and #pieces[game_tbl.selected].moves>0) then --start move with z
      making_move = true
      move_selectx = 0
    end 
    if(btnp(5)) making_move = false--cancel move with x 
  end
end


--selector listener for move
function check_selected_move()
  if(player_turn ==1) then
    if(btnp(0)) then
      move_num += 1
      if(move_num>#pieces[game_tbl.selected].moves) move_num = 1
      move_selectx = pieces[game_tbl.selected].moves[move_num]
    end
    if(btnp(1)) then
      move_num-=1
      if(move_num<1) move_num=#pieces[game_tbl.selected].moves
      move_selectx = pieces[game_tbl.selected].moves[move_num]
    end
  end
end

function computer_turn()
  player_turn = 2
  can_move = false
  --jump priority
  check_all_moves()
  if(#jumpers > 0 ) then
    comp_piece = pieces[rnd(jumpers)]
    can_move = true
  else
    comp_piece = rnd(pieces)
  end
  --otherwise random piece
  while(can_move == false) do
    
    comp_piece = rnd(pieces)
    if(#comp_piece.moves>0 and comp_piece.id < 13) then
      can_move = true
    end
  end

  move_comp = flr(rnd(#comp_piece.moves))+1
  move_comp = comp_piece.moves[move_comp]

  if(move_comp == 2) then --right jump
    mset(comp_piece.x+1, comp_piece.y+1, 96) --removes jumped piece
    for i=13,24 do
      if(pieces[i].x == comp_piece.x+1 and pieces[i].y == comp_piece.y+1) pieces[i].alive = false
    end
    comp_piece.x+=2
    comp_piece.y+=2
    mset(comp_piece.x,comp_piece.y,comp_piece.spr_id)
  elseif(move_comp==-2) then--left jump
    mset(comp_piece.x-1, comp_piece.y+1, 96) --removes jumped piece
    for i=13,24 do
      if(pieces[i].x == comp_piece.x-1 and pieces[i].y == comp_piece.y+1) pieces[i].alive = false
    end
    comp_piece.x-=2
    comp_piece.y+=2
    mset(comp_piece.x,comp_piece.y,comp_piece.spr_id)
  elseif(move_comp==1) then
    comp_piece.x+=1
    comp_piece.y+=1
  elseif(move_comp==-1) then
    comp_piece.x-=1
    comp_piece.y+=1
  end
  update_checkers()
  player_turn=1

end

--checks game over (king)
function check_king()
  if pieces[game_tbl.selected].player == 1 and pieces[game_tbl.selected].y == 0 then
    game_tbl.state= "billiards"
  end
  if comp_piece.player == 2 and comp_piece.y == 7 then
    game_tbl.state = "billiards"
  end
end

--updates map to display checkers properly
function update_checkers()
  reload(0x1000, 0x1000, 0x2000)


  for i=1,24 do
    local p = pieces[i] --look at a piece p
    if(p.alive)then --draw sprites
      mset(p.x,p.y,p.spr_id)
    end
    mset(0,0,112) --unsure why the 0th position is turned red. this fixes it
  end
end


function contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end