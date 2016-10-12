# Add sprockets directives below:

class Foliage.Color
  constructor: (color) ->
    @red   = parseInt(color.slice(1, 3), 16)
    @green = parseInt(color.slice(3, 5), 16)
    @blue  = parseInt(color.slice(5, 7), 16)

  toString: () ->
    Foliage.Color.toString(this)


Foliage.Color.toString = (color) ->
  return "##{Foliage.Color.toHexCanal(color.red)}#{Foliage.Color.toHexCanal(color.green)}#{Foliage.Color.toHexCanal(color.blue)}"

Foliage.Color.toHexCanal = (integer) ->
  hex = Math.round(integer).toString(16)
  if integer <= 0
    return "00"
  else if integer < 16
    return "0" + hex
  else if integer > 255
    return "FF"
  else
    return hex

Foliage.Color.parse = (color) ->
  value =
    red:   parseInt(color.slice(1, 3), 16)
    green: parseInt(color.slice(3, 5), 16)
    blue:  parseInt(color.slice(5, 7), 16)
  return value

Foliage.Color.random = () ->
  value =
    red:   16 * Math.round(16*Math.random())
    green: 16 * Math.round(16*Math.random())
    blue:  16 * Math.round(16*Math.random())
  return Foliage.Color.toString value
