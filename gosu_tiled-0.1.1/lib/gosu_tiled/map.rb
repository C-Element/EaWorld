module Gosu
  module Tiled
    class Map
      attr_reader :tilesets, :layers, :width, :height, :near

      def initialize(window, data, data_dir)
        @window = window
        @data = data
        @data_dir = data_dir
        @width = data['width'] * data['tilewidth']
        @height = data['height'] * data['tileheight']
        @tilesets = Tilesets.new(window, data['tilesets'], data_dir)
        @layers = Layers.new(window, data['layers'], width: @width, height: @height, tile_width: data['tilewidth'],
                             tile_height: data['tileheight'])
        @collision_coord, @npc_coord = build_collision_coord # Instance variable to store coords
        @near = nil
      end

      def draw(offset_x, offset_y)
        @layers.each do |layer|
          layer.draw(offset_x, offset_y, tilesets)
        end
      end


      ### All to down implemented by Clemente Jr

      def collides? (x, y, obj_width)
        @collision_coord.each { |object|
          (x..x + obj_width).each { |obj_x|
            if object[1][0] <= y && y <= object[1][1]
              if object[0][0] <= obj_x && obj_x <= object[0][1]
                @near = false
                return true
              end
            end
          }
        }
        @npc_coord.keys.each { |key|
          (x..x + obj_width).each { |obj_x|
            if @npc_coord[key][1][0] <= y && y <= @npc_coord[key][1][1]
              if @npc_coord[key][0][0] <= obj_x && obj_x <= @npc_coord[key][0][1]
                @near = key
                return true
              end
            end
          }
        }
        @near = false
        false
      end

      private
      def build_collision_coord
        objects = nil
        collision_pos = []
        objects_pos = {}
        @data['layers'].each { |l|
          if l['name'] == 'Collision'
            objects = l['objects']
            break
          end
        }
        if objects
          objects.each { |obj|
            if obj['name'] == ''
              collision_pos << [[obj['x'], obj['x'] + obj['width']], [obj['y'], obj['y'] + obj['height']]]
            else
              objects_pos[obj['name']] = [[obj['x'], obj['x'] + obj['width']], [obj['y'], obj['y'] + obj['height']]]
            end
          }
        end
        return collision_pos, objects_pos
      end
    end
  end
end