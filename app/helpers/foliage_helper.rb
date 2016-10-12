require 'foliage'

module FoliageHelper
  # Example of how to use in HAML view:
  #
  #   = foliage do |leaf|
  #     - leaf.serie :data, <data>
  #     - leaf.background "openstreetmap.hot"
  #     - leaf.background "openweather.precipitations"
  #     - leaf.background "openweather.heat"
  #     - leaf.choropleth :<property>, :data
  #     - leaf.control :fullscreen
  #     - leaf.control :layer_selector
  #     - leaf.control :background_selector
  #     - leaf.control :search
  #
  def foliage(options = {}, html_options = {})
    theme_colors = ['#2f7ed8', '#0d233a', '#8bbc21', '#910000', '#1aadce', '#492970', '#f28f43', '#77a1e5', '#c42525', '#a6c96a']
    leaf = Foliage::Leaf.new({ categories_colors: theme_colors }.merge(options))
    yield leaf
    content_tag(:div, nil, html_options.deep_merge(data: { leaf: leaf.to_json }))
  end
end
