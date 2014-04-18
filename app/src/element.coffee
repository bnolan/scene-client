define [], () ->
  class Element
    constructor: (@id) ->
      @position = new THREE.Vector3 0, 0, 0
      @rotation = new THREE.Euler 0, 0, 0
      @scale = new THREE.Vector3 0, 0, 0

    getInnerXML: ->
      el = $("<xml><#{@nodeName} /></xml>")

      child = el.children()
      child.attr 'position', [@position.x, @position.y, @position.z].join(" ")
      child.attr 'rotation', [@rotation.x, @rotation.y, @rotation.z].join(" ")
      child.attr 'scale', [@scale.x, @scale.y, @scale.z].join(" ")

      if @src
        child.attr 'src', @src 

      el.html()

    notify: ->
      # ...
      
  Element