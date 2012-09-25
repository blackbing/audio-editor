define (require)->
  requestFileSystem = window.requestFileSystem or window.webkitRequestFileSystem
  BlobBuilder = window.WebKitBlobBuilder or window.MozBlobBuilder
  URL = window.URL or window.webkitURL

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
