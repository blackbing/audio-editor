define (require)->

  BinaryWriter = require('../lib/binary-writer')
  BinaryReader = require('../lib/binary-reader')

  BlobBuilder = window.WebKitBlobBuilder or window.MozBlobBuilder
  URL = window.URL or window.webkitURL

  class WaveTrack
    convertIntToFloat = (value, waveBitsPerSample, signedBorder)->
      (if (waveBitsPerSample is 8) then (if (value is 0) then -1.0 else value / signedBorder - 1.0) else (if (value is 0) then 0 else value / signedBorder))
    convertFloatToInt = (value, waveBitsPerSample, signedBorder) ->
      (if (waveBitsPerSample is 8) then (value + 1.0) * signedBorder else value * signedBorder)
    @sampleRate = 0
    @audioSequences = []
    signedBorders = [ 0, 0xFF - 0x80, 0xFFFF - 0x8000, 0xFFFFFFFFF - 0x80000000 ]

    fromAudioSequences: (sequences)->
      return  if sequences.length is 0
      sampleRateCheck = sequences[0].sampleRate
      lengthCheck = sequences[0].data.length
      i = 1

      while i < sequences.length
        throw "The input sequences must have the same length and samplerate"  if sequences[i].sampleRate isnt sampleRateCheck or sequences[i].data.length isnt lengthCheck
        ++i
      @sampleRate = sampleRateCheck
      @audioSequences = sequences
      null

    toBlobUrl: (encoding)->
      encodedWave = @encodeWaveFile()
      bb = new BlobBuilder()
      blob = undefined
      bb.append encodedWave.buffer
      blob = bb.getBlob(encoding)

      URL.createObjectURL blob

    decodeWaveFile: (data)->
      reader = new BinaryReader(data)
      waveChunkID = reader.readString(4)
      waveChunkSize = reader.readUInt32()
      waveFormat = reader.readString(4)
      reader.gotoString "fmt "
      waveSubchunk1ID = reader.readString(4)
      waveSubchunk1Size = reader.readUInt32()
      waveAudioFormat = reader.readUInt16()
      waveNumChannels = @channels = reader.readUInt16()
      waveSampleRate = @sampleRate = reader.readUInt32()
      waveByteRate = reader.readUInt32()
      waveBlockAlign = reader.readUInt16()
      waveBitsPerSample = reader.readUInt16()
      reader.gotoString "data"
      waveSubchunk2ID = reader.readString(4)
      waveSubchunk2Size = reader.readUInt32()
      samplesPerChannel = @samplesPerChannel = waveSubchunk2Size / waveBlockAlign
      channelNames = [ "Left Channel", "Right Channel" ]
      i = 0

      while i < waveNumChannels
        @audioSequences.push new CreateNewAudioSequence(@sampleRate)
        @audioSequences[i].name = channelNames[i]
        ++i
      signBorderId = waveBitsPerSample / 8
      signedBorder = signedBorders[signBorderId]
      @gain = 0.0
      i = 0

      while i < samplesPerChannel
        channelId = 0

        while channelId < waveNumChannels
          value = (if (waveBitsPerSample is 8) then reader.readUInt8() else (if (waveBitsPerSample is 16) then reader.readInt16() else reader.readInt32()))
          value = Math.min(1.0, Math.max(-1.0, value))
          floatValue = convertIntToFloat(value, waveBitsPerSample, signedBorder)
          @audioSequences[channelId].data.push floatValue
          ++channelId
        ++i
      channelId = 0

      while channelId < waveNumChannels
        @audioSequences[channelId].gain = @audioSequences[channelId].getGain()
        ++channelId

    encodeWaveFile: ->
      waveChunkID = "RIFF"
      waveFormat = "WAVE"
      waveSubchunk1ID = "fmt "
      waveSubchunk1Size = 16
      waveAudioFormat = 1
      waveNumChannels = @audioSequences.length
      waveSampleRate = @sampleRate
      waveBitsPerSample = 16
      waveByteRate = waveSampleRate * waveNumChannels * waveBitsPerSample / 8
      waveBlockAlign = waveNumChannels * waveBitsPerSample / 8
      waveBitsPerSample = 16
      waveSamplesPerChannel = @audioSequences[0].data.length
      waveSubchunk2ID = "data"
      waveSubchunk2Size = waveSamplesPerChannel * waveBlockAlign
      waveChunkSize = waveSubchunk2Size + 36
      totalSize = waveChunkSize + 8
      writer = new BinaryWriter(totalSize)
      console.log writer
      writer.writeString waveChunkID
      writer.writeUInt32 waveChunkSize
      writer.writeString waveFormat
      writer.writeString waveSubchunk1ID
      writer.writeUInt32 waveSubchunk1Size
      writer.writeUInt16 waveAudioFormat
      writer.writeUInt16 waveNumChannels
      writer.writeUInt32 waveSampleRate
      writer.writeUInt32 waveByteRate
      writer.writeUInt16 waveBlockAlign
      writer.writeUInt16 waveBitsPerSample
      writer.writeString waveSubchunk2ID
      writer.writeUInt32 waveSubchunk2Size
      signBorderId = waveBitsPerSample / 8
      signedBorder = signedBorders[signBorderId]
      i = 0

      while i < waveSamplesPerChannel
        channelId = 0

        while channelId < waveNumChannels
          writer.writeInt16 convertFloatToInt(@audioSequences[channelId].data[i], waveBitsPerSample, signedBorder)
          ++channelId
        ++i
      writer.data

  Complex = (real, img) ->
    @real = real
    @img = img
    @plus = plus = (c) ->
      new Complex(@real + c.real, @img + c.img)

    @minus = minus = (c) ->
      new Complex(@real - c.real, @img - c.img)

    @times = times = (c) ->
      new Complex(@real * c.real - @img * c.img, @real * c.img + @img * c.real)

    @timesScalar = timesScalar = (s) ->
      new Complex(@real * s, @img * s)

    @conjugate = conjugate = ->
      new Complex(@real, -@img)

    @print = print = ->
      r = @real
      "" + r + " " + @img + ""

  printComplexArray = (a) ->
    i = 0

    while i < a.length
      console.log a[i].print() + "\n"
      ++i
    console.log "==============="


  FFTComplex = ->
    @fft = fft = (arrayOfComplex) ->
      len = arrayOfComplex.length
      return [ arrayOfComplex[0] ]  if len is 1
      debugger  if len % 2 isnt 0
      even = []
      k = 0

      while k < len / 2
        even.push arrayOfComplex[k * 2]
        ++k
      q = @fft(even)
      odd = []
      k = 0

      while k < len / 2
        odd.push arrayOfComplex[k * 2 + 1]
        ++k
      r = @fft(odd)
      y = []
      k = 0

      while k < len / 2
        kth = -2.0 * k * Math.PI / len
        wk = new Complex(Math.cos(kth), Math.sin(kth))
        y[k] = q[k].plus(wk.times(r[k]))
        y[k + len / 2] = q[k].minus(wk.times(r[k]))
        ++k
      y

    @ifft = ifft = (arrayOfComplex) ->
      len = arrayOfComplex.length
      y = []
      i = 0

      while i < len
        y[i] = arrayOfComplex[i].conjugate()
        ++i
      y = @fft(y)
      i = 0

      while i < len
        y[i] = y[i].conjugate()
        ++i
      i = 0

      while i < len
        y[i] = y[i].timesScalar(1.0 / len)
        ++i
      y


  WaveTrack
