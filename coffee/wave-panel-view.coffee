define (require)->

  wavePanel_tpl = require 'hbs!./wave-panel'
  WavePanelView = Backbone.View.extend
    className: 'audio-editor'
    events:
      'mousedown canvas': 'mousedownCanvas'

    mousedownCanvas: (event)->

      $target = $(event.target)
      $target.data(
        originalPosition:
          x: event.clientX
          y: event.clientY
      )

      $('body').bind('mousemove.draggingOnCanvas', (event)=>
        @draggingOnCanvas(event)

      )
      $('body').on('mouseup.mouseupOnCanvas', (event)=>
        $('body').unbind('mousemove.draggingOnCanvas')
        $('body').unbind('mouseup.mouseupOnCanvas')
      )

    draggingOnCanvas: (event)->

      originalPosition = @$('canvas').data('originalPosition')
      console.log originalPosition

      deltaX = event.clientX - originalPosition.x
      console.log deltaX

      if not deltaX
        return

      if deltaX>0
        left = originalPosition.x - @$el.offset().left
      else
        left = originalPosition.x - @$el.offset().left + deltaX



      @$('.audio-handler')
        .css(
          'width': Math.abs(deltaX)
          'left': left
        )



    initialize: ->
      @$el.append(wavePanel_tpl())
      @$('.audio-handler')
      .draggable(
        containment: 'parent'
        axis: "x"
      )
      .resizable(
        containment: "parent"
        handles: "e, w"
      )








