require 'gosu'
require_relative 'player'
require_relative 'monster'
require_relative 'npc'
require_relative '../gosu_tiled-0.1.1/lib/gosu_tiled'

$window = {:width => 640, :max_width => 1200, :mid_width => 320, :height => 480, :max_height => 1200,
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
    @map = Gosu::Tiled.load_json(self, 'map.json')
    # Balloons
    @balloon_twin1 = Gosu::Image.new(self, 'img/balloon_twin1.png', false)
    @balloon_twin2 = Gosu::Image.new(self, 'img/balloon_twin2.png', false)
    @balloon_blue = Gosu::Image.new(self, 'img/balloon_blue.png', false)
    @balloon_pink = Gosu::Image.new(self, 'img/balloon_pink.png', false)
    @balloon_red = Gosu::Image.new(self, 'img/balloon_red.png', false)
    # Flowers
    flower_red = Gosu::Image.new(self, 'img/red.png', false)
    flower_pink = Gosu::Image.new(self, 'img/light_pink.png', false)
    flower_blue = Gosu::Image.new(self, 'img/blue.png', false)
    @font_score = Gosu::Font.new(self, Gosu::default_font_name, 25)
    @font_time = Gosu::Font.new(self, Gosu::default_font_name, 25)
    @player = Player.new(self)
    #Guards
    @guard1 = NPC.new(self, 306, 454, 'img/guard.png')
    @guard2 = NPC.new(self, 416, 454, 'img/guard.png')
    #NPCs
    @oldman = NPC.new(self, 450, 165, 'img/oldman.png')
    @woman = NPC.new(self, 134, 114, 'img/woman.png')
    @traveler = NPC.new(self, 596, 134, 'img/traveler.png')
    # Etoi e Horea
    etoi_horea1 = Monster.new(self, 560, 582, 0)
    etoi_horea2 = Monster.new(self, 776, 448, 1, false)
    etoi_horea3 = Monster.new(self, 274, 506, 0)
    etoi_horea4 = Monster.new(self, 176, 1004, 1, false)
    etoi_horea5 = Monster.new(self, 288, 1004, 0, false)
    etoi_horea6 = Monster.new(self, 480, 1004, 1, false)
    etoi_horea7 = Monster.new(self, 128, 1042, 0)
    etoi_horea8 = Monster.new(self, 368, 1126, 1)
    etoi_horea9 = Monster.new(self, 720,80, 0)
    etoi_horea10 = Monster.new(self, 784,224, 1)
    etoi_horea11 = Monster.new(self, 960,48, 0, false)
    etoi_horea12 = Monster.new(self, 1056,48, 1, false)
    etoi_horea13 = Monster.new(self, 274, 732, 0)
    etoi_horea14 = Monster.new(self, 274, 882, 1)
    @monsters = [etoi_horea1, etoi_horea2, etoi_horea3, etoi_horea4, etoi_horea5, etoi_horea6, 
      etoi_horea7, etoi_horea8, etoi_horea9, etoi_horea10, etoi_horea11, etoi_horea12, etoi_horea13, etoi_horea14]
    bg_music = Gosu::Sample.new(self, 'sounds/melodic_adventure.ogg')
    @death_music = Gosu::Sample.new(self, 'sounds/death.wav')
    @picked_music = Gosu::Sample.new(self, 'sounds/picked.wav')
    @speed = 2
    @show_balloon = nil
    @score = 0
    @active_quest = nil
    @start_quest = Gosu.milliseconds
    @finished_quest = []
    @quest_functions = {:quest1 => {:points => 1,
                                    :last_flower => 0,
                                    :flowers_list => [],
                                    :flowers_slots => [],
                                    :time => 40,
                                    :img => flower_blue,
                                    :size => 16,
                                    :x => [800],
                                    :x_max => [880],
                                    :y => 480,
                                    :y_max => 608,
                                    :name => :quest1,
                                    :max_index => 0,
                                    :collected_points => 0
                                    },
                        :quest2 => {:points => 2,
                                    :last_flower => 0,
                                    :flowers_list => [],
                                    :flowers_slots => [],
                                    :time => 70,
                                    :img => flower_pink,
                                    :size => 16,
                                    :x => [128],
                                    :x_max => [528],
                                    :y => 1024,
                                    :y_max => 1152,
                                    :name => :quest2,
                                    :max_index => 0,
                                    :collected_points => 0},
                        :quest3 => {:points => 3,
                                    :last_flower => 0,
                                    :flowers_list => [],
                                    :flowers_slots => [],
                                    :time => 90,
                                    :img => flower_red,
                                    :size => 16,
                                    :x => [800, 928],
                                    :x_max => [880, 1104],
                                    :y => 48,
                                    :y_max => 176,
                                    :name => :quest3,
                                    :max_index => 0,
                                    :collected_points => 0}
    }
    @x = @y = 50
    @player.x = @player.def_x
    @player.y = @player.def_y
    bg_music.play(1, 1, true)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::KbA
      if @show_balloon
        if @show_balloon == 'draw_blue_msg'
          initialize_quest(:quest1)
        elsif @show_balloon == 'draw_pink_msg'
          initialize_quest(:quest2)
        elsif @show_balloon == 'draw_red_msg'
          initialize_quest(:quest3)
        end
        @show_balloon = nil
      else
        if @map.near
          if @map.near == 'Twin1'
            @show_balloon = 'draw_twin1_msg'
          elsif @map.near == 'Twin2'
            @show_balloon = 'draw_twin2_msg'
          elsif @map.near == 'Woman' && !@finished_quest.include?(:quest1) && !@active_quest
            @show_balloon = 'draw_blue_msg'
          elsif @map.near == 'Oldman' && !@finished_quest.include?(:quest2) && !@active_quest
            @show_balloon = 'draw_pink_msg'
          elsif @map.near == 'Traveler' && !@finished_quest.include?(:quest3) && !@active_quest
            @show_balloon = 'draw_red_msg'
          end
        end
      end
    elsif id == Gosu::KbSpace
      puts
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

  def initialize_quest(quest)
    @active_quest = @quest_functions[quest]
    @start_quest = Gosu.milliseconds
    count = id = 0
    while count < @active_quest[:x].size
      columns = (@active_quest[:x_max][count] - @active_quest[:x][count]) / 16
      rows = (@active_quest[:y_max] - @active_quest[:y]) / 16
      row_now = 0
      column_now = 0
      while row_now < rows
        while column_now <= columns
          @active_quest[:flowers_slots][id] = [@active_quest[:x][count] + (@active_quest[:size] * column_now), @active_quest[:y] + (@active_quest[:size] * row_now)]
          column_now += 1
          id +=1
        end
        row_now += 1
        column_now = 0
      end
      count +=1
    end
    @active_quest[:max_index] = id - 1
  end

  def add_flower
    actual_amount = @active_quest[:flowers_list].size
    while @active_quest[:flowers_list].size == actual_amount && @active_quest[:flowers_list].size != @active_quest[:flowers_slots].size
      slot = rand(0..@active_quest[:max_index])
      unless @active_quest[:flowers_list].include? @active_quest[:flowers_slots][slot]
        @active_quest[:flowers_list] << @active_quest[:flowers_slots][slot]
      end
    end
  end

  def colides_flower?(coord)
    (@player.x .. @player.x + @player.width).each { |player_x|
      if @player.y + @player.foot_dist + @y <= coord[1] + 10 && coord[1] + @active_quest[:size] <= @player.y + @player.height + @y
        if coord[0] <= player_x + @x && player_x + @x <= coord[0] + @active_quest[:size]
          return true
        end
      end
    }
    return false
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
    @death_music.play
    if @active_quest
      @score -= @active_quest[:collected_points]
      @active_quest[:collected_points] = 0
    end
  end

  def draw_twin1_msg
    @balloon_twin1.draw(200-@x, 370-@y, 10)
  end

  def draw_twin2_msg
    @balloon_twin2.draw(220-@x, 400-@y, 10)
  end

  def draw_blue_msg
    @balloon_blue.draw(20-@x, 10-@y, 10)
  end

  def draw_pink_msg
    @balloon_pink.draw(336-@x, 61-@y, 10)
  end

  def draw_red_msg
    @balloon_red.draw(482-@x, 33-@y, 10)
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
    formated_score = "%06d" % @score
    @font_score.draw("<b>PONTOS: #{formated_score}</b>", 10, 10, 10, 1, 1, 0xff000000, :default)
    @show_balloon = nil unless @map.near && @show_balloon
    if @active_quest
      time_left = get_time_left(@active_quest[:time])
      if time_left[0] > 0 || (time_left[0] == 0 && time_left[1] >= 1)
        if @active_quest[:last_flower] != time_left
          add_flower
          @active_quest[:last_flower] = time_left
        end
        formated_time = "%02d:%02d" % time_left
        @font_time.draw("<b>TEMPO RESTANTE: #{formated_time}", 370, 10, 10, 1, 1, 0xff000000, :default)
        count = 0
        while count < @active_quest[:flowers_list].size
          if colides_flower?(@active_quest[:flowers_list][count])
            @active_quest[:flowers_list].delete_at(@active_quest[:flowers_list].index(@active_quest[:flowers_list][count]))
            @score += @active_quest[:points]
            @active_quest[:collected_points] += @active_quest[:points]
            @picked_music.play
          else
            @active_quest[:img].draw(@active_quest[:flowers_list][count][0] - @x, @active_quest[:flowers_list][count][1] - @y, 1)
            count += 1
          end
        end
      else
        @finished_quest << @active_quest[:name]
        @active_quest = nil
      end
    end
    if @show_balloon
      send(@show_balloon)
    end
  end

end