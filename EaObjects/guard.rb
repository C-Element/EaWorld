require 'gosu'

C_32 = 32

class Guard
  def initialize(window, pos_x, pos_y)
    @i1, @i2, @i3, @i4, @i5, @i6, @i7, @i8, @i9, @i10, @i11, @i12 = Gosu::Image.load_tiles(window, 'guard.png', C_32, C_32, false)
    @x = pos_x
    @y = pos_y
    @next = @i2
    @last_time = -1
    @speed = 2
  end

  def draw(map_x, map_y)
    @next.draw(@x - map_x, @y - map_y, 0.9)
  end

  def collides?(map_x, map_y, player_x, player_y, speed, move_on_x=true)
    if (@x - map_x + (move_on_x ? speed : 0)) > 1

    end
  end
end