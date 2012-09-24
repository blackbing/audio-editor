define (require)->
  editorPanel_tpl = require 'hbs!./edit-handler-panel'

  EditorPanelView = Backbone.View.extend
    tagName: 'div'
    className: 'audio-handler'
    initialize: ->
      @$el.draggable(
        containment: 'parent'
        axis: "x"
      )
      @$el.resizable(
        containment: "parent"
        handles: "e, w"
      )








