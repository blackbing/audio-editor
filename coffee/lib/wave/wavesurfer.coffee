define (require)->
  WebAudio = require './webaudio'
  Drawer = require './drawer'

  WaveSurfer =
    init: (params) ->
      @webAudio = WebAudio
      @webAudio.init params
      @drawer = Drawer
      @drawer.init params
      @webAudio.proc.onaudioprocess = =>
        @onAudioProcess()

      @drawer.bindClick (percents)=>
        @playAt percents

    events: {}

    bind: (type, callback)->
      if not @events[type]?
        @events[type] = $.Callbacks()

      @events[type].add(callback)

    trigger: (type, opts)->
      if @events[type]?
        @events[type].fire(opts)

    onAudioProcess: ->
      unless @webAudio.paused
        @updatePercents()
        #@drawer.setCursorPercent @currentPercents
        @trigger('playing', @currentPercents)

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

    setSelection: (from, to)->

      @webAudio.setSelection(from, to)

    getSelection: ()->
      ##
      @webaudio.getSlection()




    export: (downloadName = 'exprot.wav')->

      blobURL = @webAudio.export()

      downloadLink = $('<a download="'+downloadName+'" href="'+blobURL+'"/>')
      downloadLink[0].click()

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
