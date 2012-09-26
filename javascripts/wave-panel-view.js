// Generated by CoffeeScript 1.3.3
(function() {

  define(function(require) {
    var WavePanelView, wavePanel_tpl;
    wavePanel_tpl = require('hbs!./wave-panel');
    return WavePanelView = Backbone.View.extend({
      className: 'audio-editor',
      events: {
        'mousedown canvas': 'mousedownCanvas'
      },
      mousedownCanvas: function(event) {
        var $target,
          _this = this;
        $target = $(event.target);
        $target.data({
          originalPosition: {
            x: event.clientX,
            y: event.clientY
          }
        });
        $('body').bind('mousemove.draggingOnCanvas', function(event) {
          return _this.draggingOnCanvas(event);
        });
        return $('body').on('mouseup.mouseupOnCanvas', function(event) {
          $('body').unbind('mousemove.draggingOnCanvas');
          return $('body').unbind('mouseup.mouseupOnCanvas');
        });
      },
      draggingOnCanvas: function(event) {
        var deltaX, left, originalPosition;
        originalPosition = this.$('canvas').data('originalPosition');
        console.log(originalPosition);
        deltaX = event.clientX - originalPosition.x;
        console.log(deltaX);
        if (!deltaX) {
          return;
        }
        if (deltaX > 0) {
          left = originalPosition.x - this.$el.offset().left;
        } else {
          left = originalPosition.x - this.$el.offset().left + deltaX;
        }
        return this.$('.audio-handler').css({
          'width': Math.abs(deltaX),
          'left': left
        });
      },
      initialize: function() {
        this.$el.append(wavePanel_tpl());
        return this.$('.audio-handler').draggable({
          containment: 'parent',
          axis: "x"
        }).resizable({
          containment: "parent",
          handles: "e, w"
        });
      }
    });
  });

}).call(this);