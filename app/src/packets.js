// Generated by CoffeeScript 1.6.2
(function() {
  define(['/app/components/tweenjs/build/tween.min.js', '/app/src/utils.js', '/app/src/elements/box.js', '/app/src/elements/model.js'], function(TWEEN_, utils, Box, Model) {
    var PacketGone, PacketIntroducing, PacketUpdate, dictionary, key, packets, value;

    PacketIntroducing = (function() {
      PacketIntroducing.id = 0x01;

      function PacketIntroducing(array) {
        var nil;

        nil = array[0], this.xml = array[1];
      }

      PacketIntroducing.prototype.toWireFormat = function() {
        return [PacketIntroducing.id, this.xml];
      };

      PacketIntroducing.prototype.process = function(scene) {
        var dom, element;

        element = scene.getElementById(this.id);
        if (element) {
          scene.removeChild(element);
        }
        console.log(this.xml);
        dom = $(this.xml).first();
        this.id = dom.attr('id');
        element = (function() {
          switch (dom.get(0).nodeName.toLowerCase()) {
            case 'box':
              return new Box(this.id);
            case 'model':
              return new Model(this.id);
            default:
              throw "Invalid element introduced";
          }
        }).call(this);
        element.position = utils.attributeToVector(dom.attr('position'));
        element.rotation = utils.attributeToEuler(dom.attr('rotation'));
        element.scale = utils.attributeToVector(dom.attr('scale'));
        if (dom.attr('src')) {
          element.src = dom.attr('src');
        }
        scene.appendChild(element);
        return true;
      };

      return PacketIntroducing;

    })();
    PacketUpdate = (function() {
      PacketUpdate.id = 0x02;

      function PacketUpdate(array) {
        var nil;

        nil = array[0], this.id = array[1], this.positionX = array[2], this.positionY = array[3], this.positionZ = array[4], this.rotationX = array[5], this.rotationY = array[6], this.rotationZ = array[7];
      }

      PacketUpdate.prototype.toWireFormat = function() {
        return [PacketUpdate.id, this.id, this.positionX, this.positionY, this.positionZ, this.rotationX, this.rotationY, this.rotationZ];
      };

      PacketUpdate.prototype.process = function(scene) {
        var element, newPosition, newRotation, tween;

        element = scene.getElementById(this.id);
        if (!element) {
          return;
        }
        newPosition = new THREE.Vector3(this.positionX, this.positionY, this.positionZ);
        if (!newPosition.equals(element.position)) {
          tween = new TWEEN.Tween({
            x: element.position.x,
            y: element.position.y,
            z: element.position.z
          });
          tween.to({
            x: newPosition.x,
            y: newPosition.y,
            z: newPosition.z
          }, 500).easing(TWEEN.Easing.Linear.None).onUpdate(function() {
            return element.position = new THREE.Vector3(this.x, this.y, this.z);
          }).start();
        }
        newRotation = new THREE.Euler(this.rotationX, this.rotationY, this.rotationZ);
        if (!newRotation.equals(element.rotation)) {
          tween = new TWEEN.Tween({
            x: element.rotation.x,
            y: element.rotation.y,
            z: element.rotation.z
          });
          tween.to({
            x: this.rotationX,
            y: this.rotationY,
            z: this.rotationZ
          }, 500).easing(TWEEN.Easing.Linear.None).onUpdate(function() {
            return element.rotation = new THREE.Euler(this.x, this.y, this.z);
          }).start();
        }
        element.notify();
        return true;
      };

      return PacketUpdate;

    })();
    PacketGone = (function() {
      PacketGone.id = 0x03;

      function PacketGone(array) {
        var nil;

        nil = array[0], this.id = array[1];
      }

      PacketGone.prototype.process = function(scene) {
        var element;

        element = scene.getElementById(this.id);
        if (!element) {
          scene.removeChild(element);
        }
        return true;
      };

      return PacketGone;

    })();
    packets = {
      "Introducing": PacketIntroducing,
      "Update": PacketUpdate,
      "Gone": PacketGone
    };
    dictionary = {};
    for (key in packets) {
      value = packets[key];
      dictionary[value.id] = value;
    }
    return {
      packets: packets,
      dictionary: dictionary
    };
  });

}).call(this);
