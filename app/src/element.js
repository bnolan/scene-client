// Generated by CoffeeScript 1.4.0
(function() {

  define([], function() {
    var Element;
    Element = (function() {

      function Element(id) {
        this.id = id;
        this.position = new THREE.Vector3(0, 0, 0);
        this.rotation = new THREE.Euler(0, 0, 0);
        this.scale = new THREE.Vector3(0, 0, 0);
      }

      Element.prototype.notify = function() {};

      return Element;

    })();
    return Element;
  });

}).call(this);
