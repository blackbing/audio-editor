define (require)->
  wavePanel = require 'hbs!wave-panel'

  wavesurfer = require 'wavesurfer/wavesurfer'
  $('body').append(wavePanel())

  $('#file').on('change', ()->
    file = $(@).prop('files')[0]
    wavesurfer.loadFile(file)
  )


  wavesurfer.init
    canvas: document.querySelector("#wave")
    cursor: document.querySelector("#wave-cursor")
    color: "#99CC00"

  wavesurfer.bindDragNDrop()
