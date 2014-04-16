// Generated by CoffeeScript 1.4.0
(function() {

  define([], function() {
    var Scene;
    Scene = (function() {

      function Scene() {
        this.childNodes = {};
      }

      Scene.prototype.getElementById = function(id) {
        return this.childNodes[id];
      };

      Scene.prototype.appendChild = function(element) {
        return this.childNodes[element.id] = element;
      };

      Scene.prototype.removeChild = function(element) {
        return this.childNodes[element.id] = null;
      };

      return Scene;

    })();
    return Scene;
  });

}).call(this);