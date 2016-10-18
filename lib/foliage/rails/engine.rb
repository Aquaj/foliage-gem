module Foliage
  module Rails
    class Engine < ::Rails::Engine
      engine_name 'foliage'
      require 'jquery-rails'
      require 'jquery-ui-rails'
    end
  end
end
