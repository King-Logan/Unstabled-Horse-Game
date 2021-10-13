function init_billiards()
  current_player = 1
  selected_piece = 1
  selection_direction = 0
  billiards_state = "choosing"
  game_state = "billiards"
  for i = 1, total_pieces do
    
    pieces[i].player = i > total_pieces / 2 and 1 or 2
    pieces[i].x = 24 + ((i - 1)%4 * 24)
    pieces[i].y = flr((i - 1) / 4) * 20 + 10
    pieces[i].friction = 0.08
  end
end


-- -------------------------
-- function _update()
--   if game_state == "billiards" then
--     update_billiards()
--   end
-- end

-- --------------------------
-- function _draw()
  
--   if game_state == "billiards" then
--     draw_billiards()
--   end
-- end


--------------------------------------
function go_nuts()
  for i = 1, total_pieces do
    pieces[i].dx = (rnd(20) - 10)
    pieces[i].dy = (rnd(20) - 10)
  end
end


------------------------------
function dist(x1, y1, x2, y2)
  distance = (x2 - x1)^2 + (y2 - y1)^2
  distance = sqrt(distance)
  return distance
end


---------------------------------
function draw_billiards()
  map(16, 0, 0, 0)
  -- draw pieces
  for i = 1, total_pieces do
    if(pieces[i].alive) then
      spr(pieces[i].player + 127, pieces[i].x, pieces[i].y)
    end
  end
  -- draw selecty box
  if(billiards_state == "choosing") then
    spr(135, pieces[selected_piece].x, pieces[selected_piece].y)
  end
  -- draw shooty zooty
  if(billiards_state == "aiming") then
    -- draw aiming lazers
    line(pieces[selected_piece].x + 4, pieces[selected_piece].y + 4, pieces[selected_piece].x+4+pieces[selected_piece].dx, pieces[selected_piece].y+4+pieces[selected_piece].dy, 10)
    -- redraw sprite over the aiming line
    spr(pieces[selected_piece].player + 127, pieces[selected_piece].x, pieces[selected_piece].y)
    -- wee circle on the end of the aiming lazer
    circ(pieces[selected_piece].x+4+pieces[selected_piece].dx, pieces[selected_piece].y+4+pieces[selected_piece].dy, 3, 10)
  end
end


-----------------------------------
function update_billiards()
  -- aiming and shooting
  if (billiards_state == "aiming") then
    if (btn(0)) then
      -- move shooter left
      pieces[selected_piece].dx -= 1
    elseif (btn(1)) then
      -- move shooter right
      pieces[selected_piece].dx += 1
    elseif (btn(2)) then
      -- move shooter up
      pieces[selected_piece].dy -= 1
    elseif (btn(3)) then
      -- move shooter down
      pieces[selected_piece].dy += 1
    elseif (btnp(4) or btnp(5)) then
      billiards_state = "bouncing"
      pieces[selected_piece].dy *= 0.3
      pieces[selected_piece].dx *= 0.3
      sfx(5)
      if (current_player == 1) then
        current_player = 2
      else
        current_player = 1
      end
      -- go_nuts()
    end
    -- limit dx and dy
    pieces[selected_piece].dx = min(pieces[selected_piece].dx, 32)
    pieces[selected_piece].dx = max(pieces[selected_piece].dx, -32)
    pieces[selected_piece].dy = min(pieces[selected_piece].dy, 32)
    pieces[selected_piece].dy = max(pieces[selected_piece].dy, -32)
  -- choosing a ball
  elseif (billiards_state == "choosing") then
    -- left and right keys change selected pieces
    selection_direction = 1
    if (btnp(0)) then
      selection_direction = -1
      selected_piece -= 1
      sfx(3)
    elseif (btnp(1)) then
      selection_direction = 1
      selected_piece += 1
      sfx(3)
    elseif (btnp(4) or btnp(5)) then
      billiards_state = "aiming"
      pieces[selected_piece].dy = rnd(6) - 3
      pieces[selected_piece].dx = rnd(6) - 3
      sfx(4)
      -- go_nuts()
    end
    -- make sure the selected pieces is valid for this current player
    -- and that the selected pieces is alive
    while (selected_piece < 1 or selected_piece > total_pieces or pieces[selected_piece].player != current_player or pieces[selected_piece].alive == false) do
      selected_piece += selection_direction
      if (selected_piece > total_pieces) then
        selected_piece = 1
      elseif (selected_piece < 1) then
        selected_piece = total_pieces
      end
    end
  -- bouncing balls
  elseif (billiards_state == "bouncing") then
    bouncyVibes = false
    for i = 1, total_pieces do
      if(pieces[i].alive) then
        -- check if there is any ball still moving
        if (abs(pieces[i].dx) > 0.004 or abs(pieces[i].dy) > 0.004) then
          bouncyVibes = true
        end
        -- get GULPED by the holes
        if (dist(pieces[i].x, pieces[i].y, 12, 12) < 8) then
          pieces[i].alive = false
          sfx(1)
        elseif (dist(pieces[i].x, pieces[i].y, 12, 108) < 8) then
          pieces[i].alive = false
          sfx(1)
        elseif (dist(pieces[i].x, pieces[i].y, 108, 108) < 8) then
          pieces[i].alive = false
          sfx(1)
        elseif (dist(pieces[i].x, pieces[i].y, 108, 12) < 8) then
          pieces[i].alive = false
          sfx(1)
        end
        -- bounce against de wall
        if(pieces[i].x < 2) then
          pieces[i].x = 2
          pieces[i].dx *= -1
        elseif (pieces[i].x > 118) then
          pieces[i].x = 118
          pieces[i].dx *= -1
        end
        if(pieces[i].y < 2) then
          pieces[i].y = 2
          pieces[i].dy *= -1
        elseif (pieces[i].y > 118) then
          pieces[i].y = 118
          pieces[i].dy *= -1
        end
        -- bounce against EACH OTHER
        for j = i+1, total_pieces do
          if (i != j and pieces[j].alive) do -- don't bounce against yourself for heck's sake
            d = dist(pieces[i].x + pieces[i].dx, pieces[i].y + pieces[i].dy, pieces[j].x, pieces[j].y)
            if (d < 9) then -- BANG!
              sfx(2)
              -- this part is the bouncy part
              collision_vector = {
                x = pieces[j].y - pieces[i].y,
                y = -(pieces[j].x - pieces[i].x)
              }
              velocity_vector = {
                x = pieces[i].dx - pieces[j].dx,
                y = pieces[i].dy - pieces[j].dy
              }
              -- normalize collision vector
              mag = sqrt(collision_vector.x^2 + collision_vector.y^2)
              collision_vector.x = collision_vector.x / mag
              collision_vector.y = collision_vector.y / mag
              -- dot product of two vectors
              dot = (collision_vector.x * velocity_vector.x) + (collision_vector.y * velocity_vector.y)
              -- multiply collision vector by dot product
              collision_vector.x *= dot
              collision_vector.y *= dot
              -- substract collision vector from velocity vector
              velocity_vector.x -= collision_vector.x
              velocity_vector.y -= collision_vector.y
              -- BOING
              pieces[i].dx -= velocity_vector.x
              pieces[i].dy -= velocity_vector.y
              pieces[j].dx += velocity_vector.x
              pieces[j].dy += velocity_vector.y
            end
          end
        end
        -- glide gently
        pieces[i].x += pieces[i].dx
        pieces[i].y += pieces[i].dy
        -- inertia
        pieces[i].dx *= 1 - pieces[i].friction
        pieces[i].dy *= 1 - pieces[i].friction
      end
    end
    -- if the movement stops
    if (bouncyVibes == false) then
      billiards_state = "choosing"
    end
  end
end