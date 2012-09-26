define (require)->
  WebAudio = require '../lib/webaudio'
  Drawer = require './drawer'
  WaveTrack = require './wavetrack'

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

    setSelection: ()->
      ##

    getSelection: ()->
      ##




    export: ->
      waveTrack = new WaveTrack()
      sequenceList = []
      currentBuffer = @webAudio.currentBuffer

      c = 0

      while c < currentBuffer.numberOfChannels
        chan = currentBuffer.getChannelData(c)
        console.log chan
        chan.data = []
        chan.sampleRate = currentBuffer.sampleRate
        for cn in chan
          chan.data.push(cn)
        ##for testing
        chan.data = chan.data.slice(chan.data.length/2, chan.data.length)
        sequenceList.push(chan)
        c++


      waveTrack.fromAudioSequences(sequenceList)
      blobURL = waveTrack.toBlobUrl("application/octet-stream")
      downloadLink = $('<a download="export.wav" href="'+blobURL+'"/>')
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
