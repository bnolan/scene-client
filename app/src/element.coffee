define [], () ->
  class Element
    constructor: (@id) ->
      @position = new THREE.Vector3 0, 0, 0
      @rotation = new THREE.Euler 0, 0, 0
      @scale = new THREE.Vector3 0, 0, 0

    notify: ->
      # ...
      
  Element