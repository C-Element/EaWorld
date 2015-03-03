require 'gosu'
require 'json'
require_relative 'gosu_tiled/version'
require_relative 'gosu_tiled/empty_tile'
require_relative 'gosu_tiled/tilesets'
require_relative 'gosu_tiled/layer'
require_relative 'gosu_tiled/layers'
require_relative 'gosu_tiled/map'

module Gosu
  module Tiled
    def self.load_json(window, json)
      Map.new(window, JSON.load(File.open(json)), File.dirname(json))
    end
  end
end
