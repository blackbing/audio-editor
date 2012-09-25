define (require)->
  WebAudio = require('./webaudio')
  Drawer = require('./drawer')
  WaveSurfer =
    init: (params) ->
      @webAudio = WebAudio
      @webAudio.init params
      @drawer = Drawer
      @drawer.init params
      @webAudio.proc.onaudioprocess = =>
        @onAudioProcess()

      ###
      @drawer.bindClick (percents)=>
        @playAt percents

      ###

    onAudioProcess: ->
      unless @webAudio.paused
        @updatePercents()
        #@drawer.setCursorPercent @currentPercents

    updatePercents: ->
      d = @webAudio.ac.currentTime - @webAudio.lastPlay
      percents = d / @webAudio.getDuration()
      @currentPercents = @lastPlayPercents + percents

    playAt: (percents) ->
      @webAudio.play @webAudio.getDuration() * percents
      @lastPlayPercents = percents

    pause: ->
      @webAudio.pause()
      @updatePercents()

    playPause: ->
      if @webAudio.paused
        @playAt @currentPercents or 0
      else
        @pause()

    draw: ->
      @drawer.drawBuffer @webAudio.currentBuffer

    load: (src) ->
      self = this
      xhr = new XMLHttpRequest()
      xhr.responseType = "arraybuffer"
      xhr.onload = ->
        self.webAudio.loadData xhr.response, self.draw.bind(self)

      xhr.open "GET", src, true
      xhr.send()

    loadFile: (file)->
      self = this
      reader = new FileReader()
      reader.addEventListener "load", ((e) ->
        self.webAudio.loadData e.target.result, self.draw.bind(self)
      ), false

      reader.readAsArrayBuffer(file)


    bindDragNDrop: (dropTarget) ->
      self = this
      reader = new FileReader()
      reader.addEventListener "load", ((e) ->
        self.webAudio.loadData e.target.result, self.draw.bind(self)
      ), false
      (dropTarget or document).addEventListener "drop", ((e) ->
        e.preventDefault()
        file = e.dataTransfer.files[0]
        file and reader.readAsArrayBuffer(file)
      ), false

  exports = WaveSurfer
