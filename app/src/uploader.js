// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["/app/src/elements/model.js", "/app/src/packets.js"], function(Model, Packets) {
    var Uploader;
    Uploader = (function() {

      function Uploader(client) {
        var _this = this;
        this.client = client;
        this.onSuccess = __bind(this.onSuccess, this);

        this.endpoint = "//" + (this.assetServerHost()) + "/upload";
        $('body').on('dragover', function(e) {
          if (!_this.message) {
            _this.createElements();
          }
          _this.position = _this.client.detectCollision(e.originalEvent.clientX, e.originalEvent.clientY);
          return _this.position.y = 20;
        });
      }

      Uploader.prototype.assetServerHost = function() {
        return window.location.host.split(':')[0] + ":8090";
      };

      Uploader.prototype.createElements = function() {
        var _this = this;
        this.message = $("<div />").addClass("upload-message").html('<h1>Drop a file to upload..</h1\n\n<p>\n  Currently only collada <code>.dae</code> is supported, and materials and textures are discarded.\n</p>').appendTo('body');
        this.overlay = $("<div />").addClass('upload-overlay').appendTo('body');
        this.form = $("<form method='post' enctype='multipart/form-data' action='" + this.endpoint + "' />").addClass('upload-form').html('<input type="file" name="upload" />').appendTo('body');
        return this.form.find('input').change(function(e) {
          _this.submit();
          return setTimeout(function() {
            return _this.message.html("<h1>Uploading...</h1><p>This may take a while...</p>");
          }, 200);
        });
      };

      Uploader.prototype.removeElements = function() {
        if (this.message) {
          this.message.remove();
          this.overlay.remove();
          this.form.remove();
        }
        return this.message = this.overlay = this.form = null;
      };

      Uploader.prototype.onSuccess = function(text) {
        var element, packet;
        console.log("file upload complete..");
        console.log(text);
        this.removeElements();
        element = new Model;
        element.src = text;
        element.position = this.position;
        element.rotation.y = -Math.PI / 2;
        element.scale.x = element.scale.y = element.scale.z = 40.0;
        packet = new Packets.packets.Introducing([null, element.getInnerXML()]);
        return this.client.connector.sendPacket(packet.toWireFormat());
      };

      Uploader.prototype.submit = function() {
        var file,
          _this = this;
        file = this.form.find('input').get(0).files[0];
        if (!file.name.match(/dae$/i)) {
          alert("Sorry, only files of type .dae (collada) are able to be uploaded...");
          return;
        }
        if (!this.position) {
          alert("Sorry, couldnt detect drop position...");
          return;
        }
        return $.ajax({
          type: "post",
          url: this.endpoint,
          data: new FormData(this.form.get(0)),
          processData: false,
          contentType: false,
          success: this.onSuccess,
          error: function(response, text) {
            console.log("error contacting ASSet server...");
            console.log("Error was: " + text);
            return _this.removeElements();
          },
          xhrFields: {
            onprogress: function(progress) {
              var percentage;
              percentage = Math.floor((progress.total / progress.totalSize) * 100);
              console.log('progress', percentage);
              if (percentage === 100) {
                return console.log('done uploading...!');
              }
            }
          }
        });
      };

      return Uploader;

    })();
    return Uploader;
  });

}).call(this);
