// Generated by CoffeeScript 1.3.3
(function() {

  define(function(require) {
    var Drawer, exports;
    Drawer = {
      init: function(params) {
        this.canvas = params.canvas;
        this.cc = this.canvas.getContext("2d");
        this.width = this.canvas.width = params.width;
        this.height = this.canvas.height = params.height;
        if (params.color) {
          return this.cc.fillStyle = params.color;
        }
      },
      bindClick: function(callback) {
        var my;
        my = this;
        return this.canvas.addEventListener("click", (function(e) {
          var canvasPosition, percents, relX;
          canvasPosition = my.canvas.getBoundingClientRect();
          relX = e.pageX - canvasPosition.left;
          percents = relX / my.width;
          return callback(percents);
        }), false);
      },
      drawBuffer: function(bufferData) {
        var buffer, chan_sum, data, go, i, k, max, maxsum, scale, slice, sliceData, sum, _i, _j, _len, _ref,
          _this = this;
        k = bufferData[0].data.length / this.width;
        slice = Array.prototype.slice;
        maxsum = 0;
        i = 0;
        chan_sum = [];
        for (i = _i = 0, _ref = this.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          sum = 0;
          for (_j = 0, _len = bufferData.length; _j < _len; _j++) {
            buffer = bufferData[_j];
            data = buffer.data;
            sliceData = slice.call(data, i * k, (i + 1) * k);
            max = Math.max.apply(Math, sliceData);
            sum += max;
          }
          chan_sum.push(sum);
          if (sum > maxsum) {
            maxsum = sum;
          }
        }
        scale = 1 / maxsum;
        go = (function() {
          var playIdx, playStep;
          playIdx = 0;
          playStep = 5;
          return function() {
            var stepIndex, sum_i, _k;
            if (playIdx < chan_sum.length) {
              stepIndex = playIdx + playStep;
              if (stepIndex >= chan_sum.length) {
                stepIndex = chan_sum.length;
              }
              for (i = _k = playIdx; playIdx <= stepIndex ? _k <= stepIndex : _k >= stepIndex; i = playIdx <= stepIndex ? ++_k : --_k) {
                sum_i = chan_sum[i] * scale;
                _this.drawFrame.call(_this, sum_i, i);
                playIdx++;
              }
              return setTimeout(arguments.callee, 5);
            }
          };
        })();
        go();
        return this.framesPerPx = k;
      },
      drawFrame: function(value, index) {
        var h, w, x, y;
        w = 1;
        h = Math.round(value * this.height);
        x = index;
        y = Math.round((this.height - h) / 2);
        return this.cc.fillRect(x, y, w, h);
      }
      /*
          drawCursor: ->
            @cursor.style.left = @cursorPos + "px"  if @cursor
      
          setCursorPercent: (percents) ->
            pos = Math.round(@width * percents)
            @updateCursor pos  if @cursorPos isnt pos
      
          updateCursor: (pos) ->
            @cursorPos = pos
            @framePos = pos * @framesPerPx
            @drawCursor()
      */

    };
    return exports = Drawer;
  });

}).call(this);
