require 'gosu'
require_relative 'player'
require_relative 'monster'
require_relative 'guard'
require_relative '../gosu_tiled-0.1.1/lib/gosu_tiled'

$mob = {:width => 32, :mid_width => 16, :height => 32, :mid_height => 16, :def_x => 304, :def_y => 224,
        :foot_dist => 27}
$window = {:width => 640, :max_width => 1600, :mid_width => 320, :height => 480, :max_height => 1600,
           :mid_height => 240}
$full_screen = false
$last_near = nil

ARGV.each do |arg|
  if arg == '-f'
    $full_screen = true
  end
end


class EaWorldGame < Gosu::Window
  def initialize
    super 640, 480, $full_screen
    self.caption = '..:: Ea World ::..'
    @map = Gosu::Tiled.load_json(self, 'teste_mage_city.json')
    @x = @y = 50
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @player = Player.new(self, $mob[:def_x], $mob[:def_y])
    @guard1 = Guard.new(self, 306, 454)
    @guard2 = Guard.new(self, 416, 454)
    @bicho1 = Monster.new(self, 560, 582)
    @bicho2 = Monster.new(self, 776, 448, false)
    @bicho3 = Monster.new(self, 274, 506)
    @speed = 2
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::KbA
      if @map.near
        puts "Sorry, but #{@map.near} not know what speak!!"
      end
    end
  end

  def update
    if button_down?(Gosu::KbLeft)
      player_move_left
    elsif button_down?(Gosu::KbRight)
      player_move_right
    elsif button_down?(Gosu::KbUp)
      player_move_up
    elsif button_down?(Gosu::KbDown)
      player_move_down
    else
      @player.walk false
    end
    @bicho1.update(@x, @y)
    @bicho2.update(@x, @y)
    @bicho3.update(@x, @y)
    @bicho1.walk
    @bicho2.walk
    @bicho3.walk
  end

  def player_move_left
    @player.set_direction :left
    @player.walk
    if 0 < (@x - @speed)
      if @player.x == $mob[:def_x]
        @x -= @speed unless @map.collides?(@x + @player.x - @speed, @y + @player.y + $mob[:foot_dist], $mob[:width])
        return true
      elsif (@player.x - @speed) < $mob[:def_x]
        @player.x = $mob[:def_x]
      else
        @player.x -= @speed unless @map.collides?(@x + @player.x - @speed, @y + @player.y + $mob[:foot_dist], $mob[:width])
        return true
      end
    else
      if @x != 0
        @x = 0
      end
      if 0 <= (@player.x - @speed)
        @player.x -= @speed unless @map.collides?(@x + @player.x - @speed, @y + @player.y + $mob[:foot_dist], $mob[:width])
        return true
      elsif @player.x != 0
        @player.x = 0
      end
    end
    return false
  end

  def player_move_right
    @player.set_direction :right
    @player.walk
    if @x < ($window[:max_width] - $window[:width])
      if @player.x == $mob[:def_x]
        @x += @speed unless @map.collides?(@x + @player.x + @speed, @y + @player.y + $mob[:foot_dist], $mob[:width])
        return true
      elsif (@player.x + @speed) > $mob[:def_x]
        @player.x = $mob[:def_x]
      else
        @player.x += @speed unless @map.collides?(@x + @player.x + @speed, @y + @player.y + $mob[:foot_dist], $mob[:width])
        return true
      end
    else
      if @x != ($window[:max_width] - $window[:width])
        @x = ($window[:max_width] - $window[:width])
      end
      if @player.x <= ($window[:width] - $mob[:width] - @speed)
        @player.x += @speed unless @map.collides?(@x + @player.x + @speed, @y + @player.y + $mob[:foot_dist], $mob[:width])
        return true
      else
        @player.x = ($window[:width] - $mob[:width])
      end
    end
    return false
  end

  def player_move_up
    @player.set_direction :up
    @player.walk
    if 0 < (@y - @speed)
      if @player.y == $mob[:def_y]
        @y -= @speed unless @map.collides?(@x + @player.x, @y + @player.y - @speed + $mob[:foot_dist], $mob[:width])
        return true
      elsif (@player.y - @speed) < $mob[:def_y]
        @player.y = $mob[:def_y]
      else
        @player.y -= @speed unless @map.collides?(@x + @player.x, @y + @player.y - @speed + $mob[:foot_dist], $mob[:width])
        return true
      end
    else
      if @y != 0
        @y = 0
      end
      if 0 <= (@player.y - @speed)
        @player.y -= @speed unless @map.collides?(@x + @player.x, @y + @player.y - @speed + $mob[:foot_dist], $mob[:width])
        return true
      elsif @player.y != 0
        @player.y = 0
      end
    end
    return false
  end

  def player_move_down
    @player.set_direction :down
    @player.walk
    if @y < ($window[:max_height] - $window[:height])
      if @player.y == $mob[:def_y]
        @y += @speed unless @map.collides?(@x + @player.x, @y + @player.y + @speed + $mob[:height], $mob[:width])
        return true
      elsif (@player.y + @speed) > $mob[:def_y]
        @player.y = $mob[:def_y]
      else
        @player.y += @speed unless @map.collides?(@x + @player.x, @y + @player.y + @speed + $mob[:height], $mob[:width])
        return true
      end
    else
      if @y != ($window[:max_height] - $window[:height])
        @y = ($window[:max_height] - $window[:height])
      end
      if @player.y <= ($window[:height] - $mob[:height] - @speed)
        @player.y += @speed unless @map.collides?(@x + @player.x, @y + @player.y + @speed + $mob[:height], $mob[:width])
        return true
      else
        @player.y = ($window[:height] - $mob[:height])
      end
    end
    return false
  end

  def draw
    @player.draw
    @guard1.draw(@x, @y)
    @guard2.draw(@x, @y)
    @bicho1.draw
    @bicho2.draw
    @bicho3.draw
    @map.draw(@x, @y)
    if @map.near
      @font.draw("Press A to interact with #{@map.near}", 10, 10, 2, 1, 1, 0xff0082ff, :additive)
    end
  end
end