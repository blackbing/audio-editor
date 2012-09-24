define (require)->
  wavePanel = require 'hbs!./wave-panel'
  wavesurfer = require './wavesurfer/wavesurfer'
  EditorPanelView = require './edit-handler'

  $('body').append(wavePanel())
  $('#file').on('change', ()->
    file = $(@).prop('files')[0]
    wavesurfer.loadFile(file)

    editorPanelView = new EditorPanelView(
      container: $('.audio-editor')
    )

    $('.audio-editor').append(editorPanelView.$el)
  )


  wavesurfer.init
    canvas: document.querySelector("#wave")
    width: 1024
    height: 256
    cursor: document.querySelector("#wave-cursor")
    color: "#99CC00"

  #wavesurfer.bindDragNDrop()
