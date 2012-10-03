// Generated by CoffeeScript 1.3.3
(function() {

  define(function(require) {
    var Drawer, WaveSurfer, WebAudio, exports;
    WebAudio = require('./webaudio');
    Drawer = require('./drawer');
    WaveSurfer = {
      init: function(params) {
        var _this = this;
        this.webAudio = WebAudio;
        this.webAudio.init(params);
        this.drawer = Drawer;
        this.drawer.init(params);
        return this.webAudio.proc.onaudioprocess = function() {
          return _this.onAudioProcess();
        };
        /*
              @drawer.bindClick (percents)=>
                @playAt percents
        */

      },
      events: {},
      bind: function(type, callback) {
        if (!(this.events[type] != null)) {
          this.events[type] = $.Callbacks();
        }
        return this.events[type].add(callback);
      },
      trigger: function(type, opts) {
        if (this.events[type] != null) {
          return this.events[type].fire(opts);
        }
      },
      onAudioProcess: function() {
        if (!this.webAudio.paused) {
          this.updatePercents();
          return this.trigger('playing', this.currentPercents);
        }
      },
      updatePercents: function() {
        var d, percents;
        d = this.webAudio.ac.currentTime - this.webAudio.lastPlay;
        percents = d / this.webAudio.getDuration();
        return this.currentPercents = this.lastPlayPercents + percents;
      },
      playAt: function(percents) {
        this.webAudio.play(this.webAudio.getDuration() * percents);
        return this.lastPlayPercents = percents;
      },
      pause: function() {
        this.webAudio.pause();
        return this.updatePercents();
      },
      playPause: function() {
        if (this.webAudio.paused) {
          return this.playAt(this.currentPercents || 0);
        } else {
          return this.pause();
        }
      },
      setSelection: function(from, to) {
        return this.webAudio.setSelection(from, to);
      },
      getSelection: function() {
        return this.webaudio.getSlection();
      },
      "export": function(downloadName) {
        var blobURL, downloadLink;
        if (downloadName == null) {
          downloadName = 'export.wav';
        }
        blobURL = this.webAudio["export"]();
        downloadLink = $('<a download="' + downloadName + '" href="' + blobURL + '"/>');
        return downloadLink[0].click();
      },
      draw: function() {
        return this.drawer.drawBuffer(this.webAudio.currentBufferData);
      },
      load: function(src) {
        var self, xhr;
        self = this;
        xhr = new XMLHttpRequest();
        xhr.responseType = "arraybuffer";
        xhr.onload = function() {
          return self.webAudio.loadData(xhr.response, self.draw.bind(self));
        };
        xhr.open("GET", src, true);
        return xhr.send();
      },
      loadFile: function(file) {
        var reader, self;
        self = this;
        reader = new FileReader();
        reader.addEventListener("load", (function(e) {
          return self.webAudio.loadData(e.target.result, self.draw.bind(self));
        }), false);
        return reader.readAsArrayBuffer(file);
      },
      bindDragNDrop: function(dropTarget) {
        var reader, self;
        self = this;
        reader = new FileReader();
        reader.addEventListener("load", (function(e) {
          return self.webAudio.loadData(e.target.result, self.draw.bind(self));
        }), false);
        return (dropTarget || document).addEventListener("drop", (function(e) {
          var file;
          e.preventDefault();
          file = e.dataTransfer.files[0];
          return file && reader.readAsArrayBuffer(file);
        }), false);
      }
    };
    return exports = WaveSurfer;
  });

}).call(this);
