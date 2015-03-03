require 'gosu'

class Player
  attr_accessor :x, :y

  def initialize(window, pos_x, pos_y)
    @i1, @i2, @i3, @i4, @i5, @i6, @i7, @i8, @i9, @i10, @i11, @i12 = Gosu::Image.load_tiles(window, 'player.png', 32, 32, false)
    @x = pos_x
    @y = pos_y
    @next = @i1
    @last_time = -1
    @walk_group = [@i1, @i2, @i3]
    @speed = 2
  end

  def draw
    @next.draw(@x, @y, 1)
  end

  def set_direction(direction)
    case direction
      when :left
        @walk_group = [@i4, @i5, @i6]
      when :right
        @walk_group = [@i7, @i8, @i9]
      when :up
        @walk_group = [@i10, @i11, @i12]
      else # :down
        @walk_group = [@i1, @i2, @i3]
    end
  end

  def walk(yes=true)
    time_now = (Gosu.milliseconds / 100).round(0)
    if yes
      if @next == @walk_group[1]
        @next = @walk_group[0]
        @last_time = time_now
      end
      @last_time = 0 unless @walk_group.include? @next
      if time_now % 2 == 0 and time_now > @last_time
        if @next == @walk_group[0]
          @next = @walk_group[2]
        else
          @next = @walk_group[0]
        end
        @last_time = time_now
      end
    else
      @next = @walk_group[1]
    end
  end
end