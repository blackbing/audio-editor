define (require)->

  WaveTrack = require './wavetrack'

  WebAudio =
    Defaults:
      fftSize: 1024
      smoothingTimeConstant: 0.3

    ac: new (window.AudioContext or window.webkitAudioContext)
    init: (params) ->
      params = params or {}
      @fftSize = params.fftSize or @Defaults.fftSize
      @destination = params.destination or @ac.destination
      @analyser = @ac.createAnalyser()
      @analyser.smoothingTimeConstant = params.smoothingTimeConstant or @Defaults.smoothingTimeConstant
      @analyser.fftSize = @fftSize
      @analyser.connect @destination
      @proc = @ac.createJavaScriptNode(@fftSize / 2, 1, 1)
      @proc.connect @destination
      @dataArray = new Uint8Array(@analyser.fftSize)
      @paused = true

      currentBuffer = @currentBuffer

    setSource: (source) ->
      @source and @source.disconnect()
      @source = source
      @source.connect @analyser
      @source.connect @proc

    loadData: (audioData, cb) ->
      @ac.decodeAudioData audioData, ((buffer) =>
        @currentBuffer = buffer
        @lastPause = 0
        @lastPlay = 0
        @preSetBuffer(@currentBuffer)
        cb buffer
      ), Error
      console.log @ac

    preSetBuffer: (buffer)->
      currentBuffer = buffer
      currentBufferData = []
      c = 0
      while c < currentBuffer.numberOfChannels

        chan = currentBuffer.getChannelData(c)
        cloneChan =
          data : []
          sampleRate : currentBuffer.sampleRate
        #for cn in chan
        i = 0
        while(i<chan.length)
          cn = chan[i]
          cloneChan.data.push(cn)
          i+=1
        currentBufferData.push(cloneChan)
        c++


      @currentBufferData = currentBufferData




    getDuration: ->
      @currentBuffer and @currentBuffer.duration

    play: (start, end, delay) ->
      return  unless @currentBuffer
      @pause()
      @setSource @ac.createBufferSource()
      @source.buffer = @currentBuffer
      start = start or @lastPause
      end = end or @source.buffer.duration
      delay = delay or 0
      @lastPlay = @ac.currentTime
      @source.noteGrainOn delay, start, end - start
      @paused = false

    pause: (delay) ->
      return  if not @currentBuffer or @paused
      @lastPause += (@ac.currentTime - @lastPlay)
      @source.noteOff delay or 0
      @paused = true

    waveform: ->
      @analyser.getByteTimeDomainData @dataArray
      @dataArray

    frequency: ->
      @analyser.getByteFrequencyData @dataArray
      @dataArray


    export: ->
      waveTrack = new WaveTrack()

      currentBufferData = @currentBufferData

      sequenceList = []
      selection = @getSelection()


      for channel in currentBufferData
        fromIdx = channel.data.length * selection.from
        toIdx = channel.data.length * selection.to


        channelData =
          sampleRate: channel.sampleRate
          data: channel.data.slice(fromIdx, toIdx)

        sequenceList.push channelData


      waveTrack.fromAudioSequences(sequenceList)
      blobURL = waveTrack.toBlobUrl("application/octet-stream")
      blobURL

    setSelection: (from, to)->
      ##
      @selection =
        from: from
        to: to

    getSelection: ()->
      ##
      @selection

  exports = WebAudio
