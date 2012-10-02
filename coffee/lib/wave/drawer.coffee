define (require)->
  Drawer =
    init: (params) ->
      @canvas = params.canvas
      #@cursor = params.cursor
      @cc = @canvas.getContext("2d")

      @width = @canvas.width = params.width
      @height = @canvas.height = params.height
      @cc.fillStyle = params.color  if params.color

    bindClick: (callback) ->
      my = this
      @canvas.addEventListener "click", ((e) ->
        canvasPosition = my.canvas.getBoundingClientRect()
        relX = e.pageX - canvasPosition.left
        percents = relX / my.width
        callback percents
      ), false

    drawBuffer: (buffer) ->
      k = buffer.getChannelData(0).length / @width
      slice = Array::slice
      maxsum = 0
      i = 0

      chan_sum = []
      while i < @width
        sum = 0
        c = 0

        while c < buffer.numberOfChannels
          chan = buffer.getChannelData(c)
          max = Math.max.apply(Math, slice.call(chan, i * k, (i + 1) * k))
          sum += max
          c++

        chan_sum.push(sum)
        maxsum = sum  if sum > maxsum
        i++
      scale = 1 / maxsum
      ###
      i = 0
      while i < @width
        sum = 0
        c = 0

        while c < buffer.numberOfChannels
          chan = buffer.getChannelData(c)
          max = Math.max.apply(Math, slice.call(chan, i * k, (i + 1) * k))
          sum += max
          c++
        sum *= scale
        @drawFrame sum, i
        i++
      ###

      for i of chan_sum
        @drawFrame chan_sum[i], i

      chan_sum = null

      @framesPerPx = k

    drawFrame: (value, index) ->
      w = 1
      h = Math.round(value * @height)
      x = index
      y = Math.round((@height - h) / 2)
      @cc.fillRect x, y, w, h

    ###
    drawCursor: ->
      @cursor.style.left = @cursorPos + "px"  if @cursor

    setCursorPercent: (percents) ->
      pos = Math.round(@width * percents)
      @updateCursor pos  if @cursorPos isnt pos

    updateCursor: (pos) ->
      @cursorPos = pos
      @framePos = pos * @framesPerPx
      @drawCursor()
    ###

  exports = Drawer
