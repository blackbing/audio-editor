// Generated by CoffeeScript 1.3.3
(function() {

  define(function(require) {
    var WaveTrack, WebAudio, exports;
    WaveTrack = require('./wavetrack');
    WebAudio = {
      Defaults: {
        fftSize: 1024,
        smoothingTimeConstant: 0.3
      },
      ac: new (window.AudioContext || window.webkitAudioContext),
      init: function(params) {
        var currentBuffer;
        params = params || {};
        this.fftSize = params.fftSize || this.Defaults.fftSize;
        this.destination = params.destination || this.ac.destination;
        this.analyser = this.ac.createAnalyser();
        this.analyser.smoothingTimeConstant = params.smoothingTimeConstant || this.Defaults.smoothingTimeConstant;
        this.analyser.fftSize = this.fftSize;
        this.analyser.connect(this.destination);
        this.proc = this.ac.createJavaScriptNode(this.fftSize / 2, 1, 1);
        this.proc.connect(this.destination);
        this.dataArray = new Uint8Array(this.analyser.fftSize);
        this.paused = true;
        return currentBuffer = this.currentBuffer;
      },
      setSource: function(source) {
        this.source && this.source.disconnect();
        this.source = source;
        this.source.connect(this.analyser);
        return this.source.connect(this.proc);
      },
      loadData: function(audioData, cb) {
        var _this = this;
        this.ac.decodeAudioData(audioData, (function(buffer) {
          _this.currentBuffer = buffer;
          _this.lastPause = 0;
          _this.lastPlay = 0;
          _this.preSetBuffer(_this.currentBuffer);
          return cb(buffer);
        }), Error);
        return console.log(this.ac);
      },
      preSetBuffer: function(buffer) {
        var c, chan, cloneChan, cn, currentBuffer, currentBufferData, _i, _len;
        currentBuffer = buffer;
        currentBufferData = [];
        c = 0;
        while (c < currentBuffer.numberOfChannels) {
          chan = currentBuffer.getChannelData(c);
          cloneChan = {
            data: [],
            sampleRate: currentBuffer.sampleRate
          };
          for (_i = 0, _len = chan.length; _i < _len; _i++) {
            cn = chan[_i];
            cloneChan.data.push(cn);
          }
          currentBufferData.push(cloneChan);
          c++;
        }
        return this.currentBufferData = currentBufferData;
      },
      getDuration: function() {
        return this.currentBuffer && this.currentBuffer.duration;
      },
      play: function(start, end, delay) {
        if (!this.currentBuffer) {
          return;
        }
        this.pause();
        this.setSource(this.ac.createBufferSource());
        this.source.buffer = this.currentBuffer;
        start = start || this.lastPause;
        end = end || this.source.buffer.duration;
        delay = delay || 0;
        this.lastPlay = this.ac.currentTime;
        this.source.noteGrainOn(delay, start, end - start);
        return this.paused = false;
      },
      pause: function(delay) {
        if (!this.currentBuffer || this.paused) {
          return;
        }
        this.lastPause += this.ac.currentTime - this.lastPlay;
        this.source.noteOff(delay || 0);
        return this.paused = true;
      },
      waveform: function() {
        this.analyser.getByteTimeDomainData(this.dataArray);
        return this.dataArray;
      },
      frequency: function() {
        this.analyser.getByteFrequencyData(this.dataArray);
        return this.dataArray;
      },
      "export": function() {
        var blobURL, channel, channelData, currentBufferData, fromIdx, selection, sequenceList, toIdx, waveTrack, _i, _len;
        waveTrack = new WaveTrack();
        currentBufferData = this.currentBufferData;
        sequenceList = [];
        selection = this.getSelection();
        for (_i = 0, _len = currentBufferData.length; _i < _len; _i++) {
          channel = currentBufferData[_i];
          fromIdx = channel.data.length * selection.from;
          toIdx = channel.data.length * selection.to;
          channelData = {
            sampleRate: channel.sampleRate,
            data: channel.data.slice(fromIdx, toIdx)
          };
          sequenceList.push(channelData);
        }
        waveTrack.fromAudioSequences(sequenceList);
        blobURL = waveTrack.toBlobUrl("application/octet-stream");
        return blobURL;
      },
      setSelection: function(from, to) {
        return this.selection = {
          from: from,
          to: to
        };
      },
      getSelection: function() {
        return this.selection;
      }
    };
    return exports = WebAudio;
  });

}).call(this);
