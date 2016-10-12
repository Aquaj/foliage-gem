module Foliage
  class Leaf
    def initialize(config = {})
      @config = config
      @categories_colors = @config.delete(:categories_colors)
      @config[:backgrounds] = map_backgrounds
    end

    def map_backgrounds
      [
        {
          name: 'OpenStreetMap Hot',
          url: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          referenceName: 'open_street_map.hot',
          attribution: '&copy; <a href=\'http://openstreetmap.org\'>OpenStreetMap</a> contributors, <a href=\'http://creativecommons.org/licenses/by-sa/2.0/\'>CC-BY-SA</a>, Tiles courtesy of <a href=\'http://hot.openstreetmap.org/\' target=\'_blank\'>Humanitarian OpenStreetMap Team</a>',
          tms: false,
          byDefault: true
        },
        {
          name: 'Thunderforest Landscape',
          url: 'https://{s}.tile.thunderforest.com/landscape/{z}/{x}/{y}.png',
          referenceName: 'thunderforest.landscape',
          attribution:
           'Maps © <a href=\'http://www.thunderforest.com\'>Thunderforest</a>, Data © <a href=\'http://www.openstreetmap.org/copyright\'>OpenStreetMap contributors</a>',
          subdomains: 'abc',
          tms: false,
          byDefault: false
        },
        {
          name: 'Stamen Watercolor',
          url: 'http://{s}.tile.stamen.com/watercolor/{z}/{x}/{y}.jpg',
          referenceName: 'stamen.watercolor',
          attribution: 'Map tiles by <a href=\'http://stamen.com\'>Stamen Design</a>, <a href=\'http://creativecommons.org/licenses/by/3.0\'>CC BY 3.0</a> &mdash; Map data &copy; <a href=\'http://openstreetmap.org\'>OpenStreetMap</a> contributors, <a href=\'http://creativecommons.org/licenses/by-sa/2.0/\'>CC-BY-SA</a>',
          subdomains: 'abcd',
          minZoom: 3,
          maxZoom: 15,
          tms: false,
          byDefault: false
        },
        {
          name: 'Esri World imagery',
          url: 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          referenceName: 'esri.world_imagery',
          attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
          tms: false,
          byDefault: false
        }
      ]
    end

    def background(layer, options = {})
      # allow to add custom background
      options[:name] = layer.name if layer.name?
      options[:url] = layer.url if layer.url?
      options[:by_default] = layer.by_default if layer.by_default?
      @config[:backgrounds] ||= []
      @config[:backgrounds] << options
    end

    def overlay(name, provider_name)
      @config[:overlays] ||= []
      @config[:overlays] << { name: name, provider_name: provider_name }
    end

    # def layer(name, list = {})
    #   @config[:layers] ||= []
    #   @config[:layers] << {name: name, list: list}
    # end

    def layer(name, serie, options = {})
      options[:label] = name.to_s.humanize unless options[:label]
      name = name.to_s.parameterize.tr('-', '_') unless name.is_a?(Symbol)
      @config[:layers] ||= []
      @config[:layers] << { reference: name.to_s.camelcase(:lower) }.merge(options.merge(name: name, serie: serie.to_s.camelcase(:lower)))
    end

    def simple(name, serie, options = {})
      layer(name, serie, options.merge(type: :simple))
    end

    def choropleth(name, serie, options = {})
      layer(name, serie, options.merge(type: :choropleth))
    end

    def bubbles(name, serie, options = {})
      layer(name, serie, options.merge(type: :bubbles))
    end

    def heatmap(name, serie, options = {})
      layer(name, serie, options.merge(type: :heatmap))
    end

    def band(name, serie, options = {})
      layer(name, serie, options.merge(type: :band))
    end

    def categories(name, serie, options = {})
      layer(name, serie, { colors: @categories_colors }.merge(options.merge(type: :categories)))
    end

    def paths(name, serie, options = {})
      layer(name, serie, { colors: @categories_colors }.merge(options.merge(type: :paths)))
    end

    def path(name, serie, options = {})
      layer(name, serie, { colors: @categories_colors }.merge(options.merge(type: :path)))
    end

    def points(name, serie, options = {})
      layer(name, serie, { colors: @categories_colors }.merge(options.merge(type: :points)))
    end

    def point_group(name, serie, options = {})
      layer(name, serie, options.merge(type: :point_group))
    end

    # def multi_points(name, serie, options = {})
    #   layer(name, serie, options.merge(type: :multi_points))
    # end

    # Add a serie of geo data
    def serie(name, data)
      raise StandardError, 'data must be an array. Got: ' + data.class.name unless data.is_a? Array
      @config[:series] ||= {}.with_indifferent_access
      @config[:series][name] = data.compact.collect do |item|
        next unless item[:shape]
        item
          .merge(shape: item[:shape])
          .merge(item[:popup] ? { popup: compile_leaf_popup(item[:popup], item) } : {})
      end.compact
    end

    # Add a control
    def control(name, options = true)
      @config[:controls] ||= {}.with_indifferent_access
      @config[:controls][name.to_s.camelize(:lower)] = options
    end

    def to_json
      @config.deep_transform_keys do |key|
        key.to_s.camelize(:lower)
      end.to_json
    end

    protected

    # Build a data structure for popup building
    def compile_leaf_popup(object, item)
      if object.is_a?(TrueClass)
        hash = { header: item[:name] }
        for key, value in item
          unless [:header, :footer, :name, :shape].include?(key)
            hash[key] = value.to_s
          end
        end
        compile_leaf_popup(hash, item)
      elsif object.is_a?(String)
        return [{ type: :content, content: object }]
      elsif object.is_a?(Hash)
        blocks = []
        if header = object[:header]
          blocks << compile_block(header, :header, content: item[:name])
        end
        if content = object[:content]
          if content.is_a? String
            blocks << { type: :content, content: content }
          elsif content.is_a? Array
            for value in content
              block = {}
              if value.is_a? String
                block[:content] = value
              elsif value.is_a? Hash
                block.update(value)
              else
                raise "Not implemented array block for #{object.class}"
              end
              if block[:label].is_a?(TrueClass)
                block[:label] = "attributes.#{attribute}".t(default: ["labels.#{attribute}".to_sym, attribute.to_s.humanize])
              elsif !block[:label]
                block.delete(:label)
              end
              blocks << block.merge(type: :content)
            end
          elsif content.is_a? Hash
            for attribute, value in content
              block = {}
              if value.is_a? String
                block[:content] = value
              elsif value.is_a? Hash
                block.update(value)
              elsif value.is_a? TrueClass
                block[:value] = item[attribute].to_s
                block[:label] = true
              end
              if block[:label].is_a?(TrueClass)
                block[:label] = attribute.to_s.humanize
              elsif !block[:label]
                block.delete(:label)
              end
              blocks << block.merge(type: :content)
            end
          else
            raise "Not implemented content for #{content.class}"
          end
        end
        if footer = object[:footer]
          blocks << compile_block(footer, :footer, content: item[:name])
        end
        return blocks
      else
        raise "Not implemented for #{object.class}"
      end
    end

    def compile_block(*args)
      options = args.extract_options!
      info = args.shift
      type = args.shift || options[:type]
      if info.is_a? String
        block = { type: type, content: info }
      elsif info.is_a? TrueClass
        if options[:content]
          block = { type: type, content: options[:content] }
        else
          raise StandardError, 'Option :content must be given when info is a TrueClass'
        end
      elsif info.is_a? Hash
        block = info.merge(type: type)
      else
        raise StandardError, "Not implemented #{type} for #{object.class}"
      end
      block
    end
  end
end