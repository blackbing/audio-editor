define (require)->
  WavePanelView = require './wave-panel-view'

  $('#file').on('change', ()->
    $('.audio-editor').remove()
    wavePanelView = new WavePanelView(
      width: 1024
      height: 256
      color: '#99CC00'
    )

    $('#wave_container').append(wavePanelView.$el)

    file = $(@).prop('files')[0]
    wavePanelView.loadFile(file)


    #$('.audio-editor').append(editorPanelView.$el)

    ###
    $('#export').click(()->
      wavesurfer.export()
    )
    ###
  )

  $('#choose').on('click', ()->
    $('#file').trigger('click')
  )



  #wavesurfer.bindDragNDrop()
