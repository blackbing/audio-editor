define (require)->

  wavetrack_worker_js = require 'text!./wavetrack_worker.js'

  #WaveTrack = require './wavetrack'
  URL = window.URL or window.webkitURL

  class WebAudio
    Defaults:
      fftSize: 1024
      smoothingTimeConstant: 0.3
      sampleRate: 44100/2

    ac: new (window.AudioContext or window.webkitAudioContext)
    constructor: (params) ->
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
      _dfr = $.Deferred()
      @ac.decodeAudioData audioData, ((buffer) =>
        @currentBuffer = buffer
        @lastPause = 0
        @lastPlay = 0
        @preSetBuffer(@currentBuffer)
        cb buffer
        _dfr.resolve()
      ), Error

      _dfr

    preSetBuffer: (buffer)->
      console.time('preSetBuffer')
      currentBuffer = buffer
      currentBufferData = []
      step = currentBuffer.sampleRate/@Defaults.sampleRate
      c = 0
      while c < currentBuffer.numberOfChannels

        chan = currentBuffer.getChannelData(c)
        cloneChan =
          data : []
          sampleRate : @Defaults.sampleRate
        #for cn in chan
        i = 0
        while(i<chan.length)
          cn = chan[i]
          cloneChan.data.push(cn)
          i+=step
        currentBufferData.push(cloneChan)
        c++


      @currentBufferData = currentBufferData
      console.timeEnd('preSetBuffer')





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

      ###
      waveTrack = new WaveTrack()

      currentBufferData = @currentBufferData

      sequenceList = []
      selection = @getSelection()


      for channel in currentBufferData
        fromIdx = channel.data.length * selection.from
        toIdx = channel.data.length * selection.to


        channelData =
          sampleRate: @Defaults.sampleRate
          data: channel.data.slice(fromIdx, toIdx)

        sequenceList.push channelData


      waveTrack.fromAudioSequences(sequenceList)
      blobURL = waveTrack.toBlobURL("audio/x-wav")
      dataURL = waveTrack.toDataURL()

      {
        dataURL: dataURL
        blobURL: blobURL
      }
      ###########

      _dfr = $.Deferred()
      currentBufferData = @currentBufferData

      selection = @getSelection()
      for channel in currentBufferData
        fromIdx = channel.data.length * selection.from
        toIdx = channel.data.length * selection.to

        channel.fromIdx = fromIdx
        channel.toIdx = toIdx


      console.time('wavetrack_worker')
      #worker = new Worker('assets/lib/audio-editor/lib/wave/wavetrack_worker.js')
      blobWorker = new Blob([wavetrack_worker_js])
      blobWorker_url = URL.createObjectURL(blobWorker)
      wavetrack_worker = new Worker(blobWorker_url)
      wavetrack_worker.onmessage = (event)->
        encodedWave = event.data
        blob = new Blob([encodedWave.buffer], {
          type: "audio/wav"
        })

        blobURL = webkitURL.createObjectURL blob
        #dataURL = cryptoHelpers.base64.encode(encodedWave)
        console.timeEnd('wavetrack_worker')
        _dfr.resolve({
          #dataURL: dataURL
          blobURL: blobURL
        })

      for channel in currentBufferData
        wavetrack_worker.postMessage(channel)

      _dfr

    setSelection: (from, to)->
      ##
      @selection =
        from: from
        to: to

    getSelection: ()->
      ##
      @selection


    timeStamp2text: (ts)->
      mm = Math.floor(ts/60)
      #mm = _.string.pad(mm, 2, '0')
      ss = (ts - 60*mm).toFixed(0)
      #ss = _.string.pad(ss, 2, '0')
      [mm, ss].join(':')

    getSelectedDuration: ()->


      duration = @getDuration()
      selection = @getSelection()
      return if not duration or not selection
      selectedDuration = (selection.to - selection.from) * duration

      ###
      mm = Math.floor(selectedDuration/60)
      ss = (selectedDuration - 60*mm).toFixed(2)
      [mm, ss]
      ###
      @timeStamp2text(selectedDuration)


    destroy: ->
      @proc.disconnect(0)
      @pause()
      delete @source if @source?
      delete @analyser if @analyser?
      @proc.onaudioprocess = null
      delete @proc if @proc?
      delete @ac if @ac?


  exports = WebAudio
