define (require)->

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

    setSource: (source) ->
      @source and @source.disconnect()
      @source = source
      @source.connect @analyser
      @source.connect @proc

    loadData: (audioData, cb) ->
      self = this
      @ac.decodeAudioData audioData, ((buffer) ->
        self.currentBuffer = buffer
        self.lastPause = 0
        self.lastPlay = 0
        cb buffer
      ), Error

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

    setSelection: (from, to)->

      ##

  exports = WebAudio
