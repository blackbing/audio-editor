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

    drawBuffer: (bufferData) ->
      k = bufferData[0].data.length/@width
      slice = Array.prototype.slice

      maxsum = 0
      i = 0

      chan_sum = []

      for i in [0..@width-1]
        sum = 0
        for buffer in bufferData
          data = buffer.data
          sliceData = slice.call(data, i*k, (i+1)*k)

          max = Math.max.apply(Math, sliceData)
          sum += max

        chan_sum.push(sum)
        maxsum = sum  if sum > maxsum

      scale = 1/maxsum


      ##make it as animation
      go = do ()=>
        playIdx = 0
        playStep = 10
        =>
          #check ending length
          if playIdx < chan_sum.length
            stepIndex = playIdx+playStep
            if stepIndex >= chan_sum.length
              stepIndex = chan_sum.length
            for i in [playIdx..stepIndex]
              sum_i = chan_sum[i]*scale
              @drawFrame.call(@, sum_i, i)
              playIdx++
            setTimeout(arguments.callee, 1)
          else
            console.log 'stop'

      go()

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
