define (require)->
  wavesurfer = require './lib/wave/wavesurfer'
  WavePanelView = require './wave-panel-view'

  $('#file').on('change', ()->
    $('.audio-editor').remove()
    wavePanelView = new WavePanelView()

    $('#wave_container').append(wavePanelView.$el)
    wavesurfer.init
      canvas: document.querySelector("#wave")
      width: 1024
      height: 256
      cursor: document.querySelector("#wave-cursor")
      color: "#99CC00"

    file = $(@).prop('files')[0]
    wavesurfer.loadFile(file)


    #$('.audio-editor').append(editorPanelView.$el)

    $('#export').click(()->
      wavesurfer.export()
    )
  )

  $('#choose').on('click', ()->
    $('#file').trigger('click')
  )



  #wavesurfer.bindDragNDrop()
