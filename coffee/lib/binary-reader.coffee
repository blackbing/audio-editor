define (require)->
  requestFileSystem = window.requestFileSystem or window.webkitRequestFileSystem
  BlobBuilder = window.WebKitBlobBuilder or window.MozBlobBuilder
  URL = window.URL or window.webkitURL

  class BinaryReader

    constructor: (data) ->
      @data = new Uint8Array(data)
      @pos = 0
      @signMasks = [ 0x0, 0x80, 0x8000, 0x800000, 0x80000000 ]
      @masks = [ 0x0, 0xFF + 1, 0xFFFF + 1, 0xFFFFFF + 1, 0xFFFFFFFF + 1 ]

    gotoString: (value) ->
      i = @pos

      while i < @data.length
        if value[0] is String.fromCharCode(@data[i])
          complete = true
          j = i

          while j < value.length + i
            unless value[j - i] is String.fromCharCode(@data[j])
              complete = false
              break
            ++j
          if complete is true
            @pos = i
            break
        ++i

    readUInt8: (bigEndian) ->
      @readInteger 1, false, bigEndian

    readInt8: (bigEndian) ->
      @readInteger 1, true, bigEndian

    readUInt16: (bigEndian) ->
      @readInteger 2, false, bigEndian

    readInt16: (bigEndian) ->
      @readInteger 2, true, bigEndian

    readUInt32: (bigEndian) ->
      @readInteger 4, false, bigEndian

    readInt32: (bigEndian) ->
      @readInteger 4, true, bigEndian

    readString: (size) ->
      r = ""
      i = 0
      i = 0
      while i < size
        r += String.fromCharCode(@data[@pos++])
        ++i
      r

    readInteger: (size, signed, bigEndian) ->
      throw "Buffer overflow during reading."  if @pos + (size - 1) >= @data.length
      i = 0
      r = 0
      i = 0
      while i < size
        if bigEndian is true
          r = @data[@pos++] + (r << (i * 8))
        else
          r += (@data[@pos++] << (i * 8))
        ++i
      r = r - @masks[size]  if signed and r & @signMasks[size]
      r

    eof: ->
      @data.length >= @pos



  exports = BinaryReader
