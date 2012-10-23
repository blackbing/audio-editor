define (require)->

  wavesurfer = require './lib/wave/wavesurfer'
  wavePanel_tpl = require 'hbs!./wave-panel'




  WavePanelView = Backbone.View.extend
    className: 'audio-editor-container'
    events:
      'mousedown canvas': 'mousedownCanvas'
      'click .playpause': 'playPause'

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
        @selectionDrop()
        $('body').unbind('mousemove.draggingOnCanvas')
        $('body').unbind('mouseup.mouseupOnCanvas')
      )

    draggingOnCanvas: (event)->

      originalPosition = @$('canvas').data('originalPosition')

      deltaX = event.clientX - originalPosition.x

      if not deltaX
        return

      duration = wavesurfer.webAudio.getDuration()
      maxWidth = Math.floor(@options.resizeMaxDuration/duration * @options.width)

      if deltaX>0
        left = originalPosition.x - @$('.audio-editor').offset().left
      else
        left = originalPosition.x - @$('.audio-editor').offset().left + deltaX

      width = Math.abs(deltaX)
      width = if width<maxWidth then width else maxWidth
      @audioHandler
        .css(
          'width': width
          'left': left
        )

      @selectionChanged()

    selectionChanged: ()->
      left = parseFloat(@audioHandler.css('left'))
      width = @audioHandler.outerWidth()

      from = left/@canvasWidth
      to = (left+width)/@canvasWidth

      wavesurfer.setSelection(from, to)
      selectedDuration = wavesurfer.webAudio.getSelectedDuration()
      if selectedDuration
        #console.log selectedDuration

        from_ts = from * wavesurfer.webAudio.getDuration()
        from_text = wavesurfer.webAudio.timeStamp2text(from_ts)
        to_ts = to * wavesurfer.webAudio.getDuration()
        to_text = wavesurfer.webAudio.timeStamp2text(to_ts)
        @$('#handler_left > span').text(from_text)
        @$('#handler_right > span').text(to_text)

        @$('.handler-ts').text(selectedDuration)


    selectionDrop: ()->
      left = parseFloat(@audioHandler.css('left'))
      from = left/@canvasWidth
      wavesurfer.playAt(from)
      @playStauseUpdated()

    playStauseUpdated: ()->
      if not wavesurfer.webAudio.paused
        @$('.playpause').removeClass('play').addClass('pause')
      else
        @$('.playpause').removeClass('pause').addClass('play')

    exportAudio: ()->
      wavesurfer.pause()
      @$('.audio-editor').addClass('loading')
      wavesurfer.export().pipe((exportObj )=>
        selectedDuration = wavesurfer.webAudio.getSelectedDuration()

        @$('.audio-editor').removeClass('loading')
        $.extend(exportObj,
          filename : @$('#audio-name').val()
          formated_time_length: selectedDuration
        )

      )


    playPause: ()->
      wavesurfer.playPause()
      @playStauseUpdated()


    updatePlaying: (percentage)->
      @$('.playing-pointer').css('left', "#{percentage*100}%")
      @$('.playing-pointer').css('left', "#{percentage*100}%")
      @$('.audio-progress .bar').css('width', "#{percentage*100}%")

      duration = wavesurfer.webAudio.getDuration()
      currentTs = percentage * duration

      currentTs_text = wavesurfer.webAudio.timeStamp2text(currentTs)
      duration_text = wavesurfer.webAudio.timeStamp2text(duration)
      @$('.current-time').text("#{currentTs_text}/#{duration_text}")


    initialize: (@options)->
      options.resizeMaxDuration = options.resizeMaxDuration || 45 # 45 sec
      options.resizeDefaultDuration = options.resizeDefaultDuration|| 30 # 45 sec

      @render()

    render: ()->
      options = @options
      tpl = wavePanel_tpl()
      @$el.append(tpl)


      wavesurfer.init
        canvas: @$('canvas')[0]
        width: options.width
        height: options.height
        #cursor: document.querySelector("#wave-cursor")
        color: options.color


      wavesurfer.bind('playing', (currentPercents)=>
        @updatePlaying.apply(@, arguments)
      )


      @audioHandler = @$('.audio-handler')
      @canvasWidth = options.width

      @audioHandler
      .draggable(
        containment: 'parent'
        axis: "x"
        drag: ()=>
          @selectionChanged.apply(@, arguments)
        stop: ()=>
          @selectionDrop.apply(@, arguments)
      )
      .resizable(
        containment: "parent"
        handles: "" # XXX jquery.ui.widget bug, it do deep extend. would cause object and array(default option) be extended to a strange object
        resize: ()=>
          @selectionChanged.apply(@, arguments)
        stop: ()=>
          @selectionDrop.apply(@, arguments)
      )

      @$('.handle-bar').draggable(
        containment: ".audio-progress"
        axis: 'x'
        stop: (event, ui)=>
          deltaX = ui.position.left

          from = (deltaX / @$('.audio-editor').width()) + (parseFloat(@$('.bar').prop('style').width) * 0.01)
          #update percentage
          wavesurfer.playAt(from)

          #remove left
          ui.helper.prop('style').left = ''
          @playStauseUpdated()
      )

      @selectionChanged()


    loadFile: (file)->
      @$('#audio-name').attr(
        placeholder: file.name
        value: file.name
      )

      @$('.audio-editor').addClass('loading')
      console.time 'loadFile'
      _dfr = wavesurfer.loadFile(file)
      _dfr.done( =>

        duration = wavesurfer.webAudio.getDuration()
        @audioHandler.css(
          width: Math.floor(@options.resizeDefaultDuration/duration * @options.width)
        ).
        resizable('option',
          maxWidth: Math.floor(@options.resizeMaxDuration/duration * @options.width)
        )

        console.timeEnd 'loadFile'
        @$('.audio-editor').removeClass('loading')
        @selectionChanged()
        @updatePlaying(0)
      )



    remove: ->

      wavesurfer.destroy()





