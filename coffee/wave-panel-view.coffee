define (require)->

  wavesurfer = require './lib/wave/wavesurfer'
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

      deltaX = event.clientX - originalPosition.x

      if not deltaX
        return

      if deltaX>0
        left = originalPosition.x - @$el.offset().left
      else
        left = originalPosition.x - @$el.offset().left + deltaX



      @audioHandler
        .css(
          'width': Math.abs(deltaX)
          'left': left
        )

      @selectionChanged()

    selectionChanged: ()->
      left = parseFloat(@audioHandler.css('left'))
      width = @audioHandler.outerWidth()

      from = left/@canvasWidth
      to = (left+width)/@canvasWidth

      wavesurfer.setSelection(from, to)

    exportAudio: ()->
      wavesurfer.export()

    initialize: (options)->
      @$el.append(wavePanel_tpl())


      wavesurfer.init
        canvas: @$('canvas')[0]
        width: options.width
        height: options.height
        #cursor: document.querySelector("#wave-cursor")
        color: options.color




      @audioHandler = @$('.audio-handler')
      @canvasWidth = options.width

      @audioHandler
      .draggable(
        containment: 'parent'
        axis: "x"
        drag: ()=>
          @selectionChanged.apply(@, arguments)
      )
      .resizable(
        containment: "parent"
        handles: "e, w"
        resize: ()=>
          @selectionChanged.apply(@, arguments)
      )

    loadFile: (file)->

      wavesurfer.loadFile(file)








