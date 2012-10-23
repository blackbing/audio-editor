define (require)->
  WavePanelView = require './wave-panel-view'
  wavePanelView = null



  clearAudioView = ->
    if wavePanelView
      wavePanelView.remove()
      wavePanelView = null


  $('#file').on('change', ()->
    clearAudioView()
    file = $(@).prop('files')[0]
    wavePanelView = new WavePanelView(
      width: 990
      height: 156
      color: '#99CC00'
    )
    wavePanelView.loadFile(file)

    $('#wave_container').append(wavePanelView.$el)

  )

  $('#choose').on('click', ()->
    $('#file').trigger('click')
  )
  ###
  $('#play').click(()->
    wavePanelView.playPause()
  )
  ###
  $('#export').click(()->
    wavePanelView.exportAudio().done((exportObj)=>
      console.log 'exportObj:', exportObj
      #clearAudioView()
      blobURL = exportObj.blobURL
      downloadName = exportObj.filename
      downloadLink = $('<a download="'+downloadName+'" href="'+blobURL+'"/>')
      downloadLink[0].click()
    )
  )



  #wavesurfer.bindDragNDrop()
  console.log ('main initial')
