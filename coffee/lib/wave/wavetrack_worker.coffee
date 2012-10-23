
  class BinaryWriter

    constructor: (estimatedSize) ->
      @estimatedSize = estimatedSize
      @pos = 0
      @data = new Uint8Array(estimatedSize)
      @masks = [ 0x0, 0xFF + 1, 0xFFFF + 1, 0xFFFFFF + 1, 0xFFFFFFFF + 1 ]

    writeUInt8: (value, bigEndian) =>
      @writeInteger value, 1, bigEndian

    writeInt8: (value, bigEndian) =>
      @writeInteger value, 1, bigEndian

    writeUInt16: (value, bigEndian) =>
      @writeInteger value, 2, bigEndian

    writeInt16: (value, bigEndian) =>
      @writeInteger value, 2, bigEndian

    writeUInt32: (value, bigEndian) =>
      @writeInteger value, 4, bigEndian

    writeInt32: (value, bigEndian) =>
      @writeInteger value, 4, bigEndian

    writeString: (value) =>
      i = 0
      i = 0
      while i < value.length
        @data[@pos++] = value.charCodeAt(i)
        ++i

    writeInteger: (value, size, bigEndian) =>
      r = value
      i = 0
      r += @masks[size]  if value < 0
      i = 0
      while i < size
        if bigEndian is true
          @data[@pos++] = (r >> ((size - i - 1) * 8)) & 0xFF
        else
          @data[@pos++] = (r >> (i * 8)) & 0xFF
        ++i



  class WaveTrack
    convertIntToFloat = (value, waveBitsPerSample, signedBorder)->
      (if (waveBitsPerSample is 8) then (if (value is 0) then -1.0 else value / signedBorder - 1.0) else (if (value is 0) then 0 else value / signedBorder))
    convertFloatToInt = (value, waveBitsPerSample, signedBorder) ->
      (if (waveBitsPerSample is 8) then (value + 1.0) * signedBorder else value * signedBorder)

    sampleRate : 0
    audioSequences : []
    signedBorders : [ 0, 0xFF - 0x80, 0xFFFF - 0x8000, 0xFFFFFFFFF - 0x80000000 ]

    fromAudioSequences: (sequences)->
      return  if sequences.length is 0
      sampleRateCheck = sequences.sampleRate
      lengthCheck = sequences.data.length
      i = 1

      while i < sequences.length
        throw "The input sequences must have the same length and samplerate"  if sequences[i].sampleRate isnt sampleRateCheck or sequences[i].data.length isnt lengthCheck
        ++i

      @sampleRate = sampleRateCheck

      @audioSequences.push(sequences)
      null


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
      signedBorder = @signedBorders[signBorderId]
      i = 0

      while i < waveSamplesPerChannel
        channelId = 0

        while channelId < waveNumChannels
          writer.writeInt16 convertFloatToInt(@audioSequences[channelId].data[i], waveBitsPerSample, signedBorder)
          ++channelId
        ++i
      writer.data



  ##end of WaveTrack

  @waveTrack = null

  #worker
  @onmessage = (event)->
    channelData = event.data
    #@postMessage('sequenceList' + sequenceList.fromIdx)
    fromIdx = channelData.fromIdx
    toIdx = channelData.toIdx
    channelData.data = channelData.data.slice(fromIdx, toIdx)
    if not @waveTrack
      @waveTrack = new WaveTrack()

    @waveTrack.fromAudioSequences(channelData)

    #stero sound channel
    if @waveTrack.audioSequences.length >=2
      encodedWave = @waveTrack.encodeWaveFile()
      @postMessage(encodedWave)
