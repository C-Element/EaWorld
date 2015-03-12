require 'gosu'
require_relative 'player'
require_relative 'monster'
require_relative 'npc'
require_relative '../gosu_tiled-0.1.1/lib/gosu_tiled'

$window = {:width => 640, :max_width => 1600, :mid_width => 320, :height => 480, :max_height => 1600,
           :mid_height => 240}
$full_screen = false
$last_near = nil

$last_update = nil

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
    # Balloons
    @balloon_twin1 = Gosu::Image.new(self, 'balloon_twin1.png', false)
    @balloon_twin2 = Gosu::Image.new(self, 'balloon_twin2.png', false)
    @balloon_blue = Gosu::Image.new(self, 'balloon_blue.png', false)
    # Flowers
    flower_red = Gosu::Image.new(self, 'red.png', false)
    flower_pink = Gosu::Image.new(self, 'light_pink.png', false)
    flower_blue = Gosu::Image.new(self, 'blue.png', false)
    @x = @y = 50
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @font_score = Gosu::Font.new(self, Gosu::default_font_name, 25)
    @font_time = Gosu::Font.new(self, Gosu::default_font_name, 25)
    @player = Player.new(self)
    #Guards
    @guard1 = NPC.new(self, 306, 454, 'guard.png')
    @guard2 = NPC.new(self, 416, 454, 'guard.png')
    #NPCs
    @oldman = NPC.new(self, 450, 165, 'oldman.png')
    @woman = NPC.new(self, 134, 114, 'woman.png')
    @traveler = NPC.new(self, 596, 134, 'traveler.png')
    # Etoi e Horea
    etoi_horea1 = Monster.new(self, 560, 582)
    etoi_horea2 = Monster.new(self, 776, 448, false)
    etoi_horea3 = Monster.new(self, 274, 506)
    @monsters = [etoi_horea1, etoi_horea2, etoi_horea3]
    @speed = 2
    @show_balloon = nil
    @score = 666999
    @active_quest = nil
    @start_quest = Gosu.milliseconds
    @quest_functions = {:quest1 => {:points => 'q1_add_points',
                                    :flower => 'q1_add_flower',
                                    :last_flower => 0,
                                    :flowers_list => [],
                                    :flowers_slots => [],
                                    :time => 120,
                                    :img => flower_blue,
                                    :size => 16,
                                    :x => 800,
                                    :x_max => 880,
                                    :y => 480,
                                    :y_max => 608},
                        :quest2 => {:points => 'q2_add_points',
                                    :flower => 'q2_add_flower',
                                    :last_flower => 0,
                                    :flowers_list => [],
                                    :flowers_slots => [],
                                    :time => 120,
                                    :img => flower_pink,
                                    :size => 16,
                                    :x => 128,
                                    :x_max => 528,
                                    :y => 1024,
                                    :y_max => 1152},
                        :quest3 => {:points => 'q3_add_points',
                                    :flower => 'q3_add_flower',
                                    :last_flower => 0,
                                    :flowers_list => [],
                                    :flowers_slots => [],
                                    :time => 120,
                                    :img => flower_red,
                                    :size => 16,
                                    :x => [800, 928],
                                    :x_max => [880, 1104],
                                    :y => 48,
                                    :y_max => 1176}
    }
    initialize_q1
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::KbA
      if @show_balloon
        if @show_balloon == 'draw_blue_msg'
          initialize_q1
        end
        @show_balloon = nil
      else
        if @map.near
          if @map.near == 'Twin1'
            @show_balloon = 'draw_twin1_msg'
          elsif @map.near == 'Twin2'
            @show_balloon = 'draw_twin2_msg'
          elsif @map.near == 'Woman'
            @show_balloon = 'draw_blue_msg'
          end
        end
      end
    elsif id == Gosu::KbSpace
      150.times {
        puts "\n"
      }
      puts "#{(@x + @player.x)}, #{@y + @player.y}"
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
    @monsters.each { |monster|
      monster.update(@x, @y)
      monster.walk
      reset_player if monster.colides?(@x, @y, @player)
    }
  end

  def get_time_left(total_seconds)
    time_now = total_seconds - ((Gosu.milliseconds-@start_quest)/1000)
    minutes = time_now/60
    seconds = time_now%60
    [minutes, seconds]
  end

  def initialize_q1
    @active_quest = @quest_functions[:quest1]
    @start_quest = Gosu.milliseconds
  end

  def q1_add_flower
    size = 16
    x = 800
    x_max = 880
    y = 480
    y_max = 608
    c = 0
    actual_amount = @quest_functions[:quest1][:flowers_list].size
    while @quest_functions[:quest1][:flowers_list].size == actual_amount
      position_x = rand(x..x_max)
      position_y = rand(y..y_max)
      if actual_amount == 0
        @quest_functions[:quest1][:flowers_list] << [position_x, position_y]
      else
        @quest_functions[:quest1][:flowers_list].each { |coord|
          unless coord[1] <= position_y && position_y <= coord[1] + size && coord[0] <= position_x && position_x <= coord[0] + size
            @quest_functions[:quest1][:flowers_list] << [position_x, position_y]
          end
        }
      end
    end
  end

  def player_move_left
    @player.set_direction :left
    @player.walk
    if 0 < (@x - @speed)
      if @player.x == @player.def_x
        @x -= @speed unless @map.collides?(@x + @player.x - @speed, @y + @player.y + @player.foot_dist, @player.width)
      elsif (@player.x - @speed) < @player.def_x
        @player.x = @player.def_x
      else
        @player.x -= @speed unless @map.collides?(@x + @player.x - @speed, @y + @player.y + @player.foot_dist, @player.width)
      end
    else
      if @x != 0
        @x = 0
      end
      if 0 <= (@player.x - @speed)
        @player.x -= @speed unless @map.collides?(@x + @player.x - @speed, @y + @player.y + @player.foot_dist, @player.width)
      elsif @player.x != 0
        @player.x = 0
      end
    end
  end

  def player_move_right
    @player.set_direction :right
    @player.walk
    if @x < ($window[:max_width] - $window[:width])
      if @player.x == @player.def_x
        @x += @speed unless @map.collides?(@x + @player.x + @speed, @y + @player.y + @player.foot_dist, @player.width)
      elsif (@player.x + @speed) > @player.def_x
        @player.x = @player.def_x
      else
        @player.x += @speed unless @map.collides?(@x + @player.x + @speed, @y + @player.y + @player.foot_dist, @player.width)
      end
    else
      if @x != ($window[:max_width] - $window[:width])
        @x = ($window[:max_width] - $window[:width])
      end
      if @player.x <= ($window[:width] - @player.width - @speed)
        @player.x += @speed unless @map.collides?(@x + @player.x + @speed, @y + @player.y + @player.foot_dist, @player.width)
      else
        @player.x = ($window[:width] - @player.width)
      end
    end
  end

  def player_move_up
    @player.set_direction :up
    @player.walk
    if 0 < (@y - @speed)
      if @player.y == @player.def_y
        @y -= @speed unless @map.collides?(@x + @player.x, @y + @player.y - @speed + @player.foot_dist, @player.width)
      elsif (@player.y - @speed) < @player.def_y
        @player.y = @player.def_y
      else
        @player.y -= @speed unless @map.collides?(@x + @player.x, @y + @player.y - @speed + @player.foot_dist, @player.width)
      end
    else
      if @y != 0
        @y = 0
      end
      if 0 <= (@player.y - @speed)
        @player.y -= @speed unless @map.collides?(@x + @player.x, @y + @player.y - @speed + @player.foot_dist, @player.width)
      elsif @player.y != 0
        @player.y = 0
      end
    end
  end

  def player_move_down
    @player.set_direction :down
    @player.walk
    if @y < ($window[:max_height] - $window[:height])
      if @player.y == @player.def_y
        @y += @speed unless @map.collides?(@x + @player.x, @y + @player.y + @speed + @player.height, @player.width)
      elsif (@player.y + @speed) > @player.def_y
        @player.y = @player.def_y
      else
        @player.y += @speed unless @map.collides?(@x + @player.x, @y + @player.y + @speed + @player.height, @player.width)
      end
    else
      if @y != ($window[:max_height] - $window[:height])
        @y = ($window[:max_height] - $window[:height])
      end
      if @player.y <= ($window[:height] - @player.height - @speed)
        @player.y += @speed unless @map.collides?(@x + @player.x, @y + @player.y + @speed + @player.height, @player.width)
      else
        @player.y = ($window[:height] - @player.height)
      end
    end
  end

  def reset_player
    @x = @y = 50
    @player.x = @player.def_x
    @player.y = @player.def_y

  end

  def draw_twin1_msg
    @balloon_twin1.draw(200-@x, 370-@y, 10)
  end

  def draw_twin2_msg
    @balloon_twin2.draw(220-@x, 400-@y, 10)
  end

  def draw_blue_msg
    @balloon_blue.draw(220-@x, 400-@y, 10)
  end

  def draw
    @player.draw
    @guard1.draw(@x, @y)
    @guard2.draw(@x, @y)
    @woman.draw(@x, @y)
    @oldman.draw(@x, @y)
    @traveler.draw(@x, @y)
    @monsters.each { |monster|
      monster.draw
    }
    @map.draw(@x, @y)
    if @map.near
      @font.draw("Pressione A para interagir com #{@map.near}", 10, 30, 10, 1, 1, 0xffffffff, :default)
    else
      @show_balloon = nil
    end
    if @show_balloon
      send(@show_balloon)
    end
    if @active_quest
      time_left = get_time_left(@active_quest[:time])
      if time_left[0] > 0 || (time_left[0] == 0 && time_left[1] >= 1)
        if @active_quest[:last_flower] != time_left
          send(@active_quest[:flower])
          @active_quest[:last_flower] = time_left
        end
        formated_time = "%02d:%02d" % time_left
        @font_time.draw("<b>TEMPO RESTANTE: #{formated_time}", 370, 10, 10, 1, 1, 0xff000000, :default)
        @active_quest[:flowers_list].each { |coord|
          @active_quest[:img].draw(coord[0] - @x, coord[1] - @y, 1)
        }
      else
        @active_quest = nil
      end
    end
    @font_score.draw("<b>PONTOS: #{@score}</b>", 10, 10, 10, 1, 1, 0xff000000, :default)
  end
end