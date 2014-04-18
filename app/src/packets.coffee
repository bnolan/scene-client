define [
  '/app/components/threejs/build/three.js', 
  '/app/components/tweenjs/build/tween.min.js', 
  '/app/src/utils.js',
  '/app/src/elements/box.js',
  '/app/src/elements/model.js'
], (THREE_, TWEEN_, utils, Box, Model) ->
	class PacketIntroducing
	  @id: 0x01

	  constructor: (array) ->
      [nil, @xml] = array


    process: (scene) ->
      element = scene.getElementById(@id)

      if element
        # todo - reparse the xml without deleting / creating the element
        scene.removeChild(element)

      console.log @xml

      dom = $(@xml).first()

      @id = dom.attr('id')

      element = switch dom.get(0).nodeName.toLowerCase()
        when 'box' then new Box @id
        when 'model' then new Model @id
        else
          throw "Invalid element introduced"
      
      element.position = utils.attributeToVector(dom.attr('position'))
      element.rotation = utils.attributeToEuler(dom.attr('rotation'))
      element.scale = utils.attributeToVector(dom.attr('scale'))

      if dom.attr('src')
        element.src = dom.attr('src')

      scene.appendChild(element)

      true

    toWireFormat: ->
      [@id, @xml]

	class PacketUpdate
	  @id: 0x02

	  constructor: (array) ->
      [nil, @id, @positionX, @positionY, @positionZ, @rotationX, @rotationY, @rotationZ] = array

    _byteToEuler: (byte) ->
      byte / 256.0 * 2 * Math.PI

    process: (scene) ->
      element = scene.getElementById(@id)

      if !element
        # console.log "Trying to update non-present element #{@id}"
        return

      newPosition = new THREE.Vector3 @positionX, @positionY, @positionZ

      if !newPosition.equals(element.position)
        tween = new TWEEN.Tween( { x : element.position.x, y : element.position.y, z : element.position.z } )

        tween.to( { x : newPosition.x, y : newPosition.y, z : newPosition.z }, 500).
          easing(TWEEN.Easing.Linear.None).
          onUpdate( -> element.position = new THREE.Vector3(@x, @y, @z)).
          start()
      
      #element.position = new THREE.Vector3 @positionX, @positionY, @positionZ
      
      newRotation = new THREE.Euler @_byteToEuler(@rotationX, @rotationY, @rotationZ)

      if !newRotation.equals(element.rotation)
        tween = new TWEEN.Tween( { x : element.rotation.x, y : element.rotation.y, z : element.rotation.z } )

        tween.to( { x : @rotationX, y : @rotationY, z : @rotationZ }, 500).
          easing(TWEEN.Easing.Linear.None).
          onUpdate( -> element.rotation = new THREE.Euler(@x, @y, @z)).
          start()


      element.notify()

      true

	class PacketGone
	  @id: 0x03
	  
	  constructor: (array) ->
      [nil, @id] = array

	  process: (scene) ->
      element = scene.getElementById(@id)

      if !element
        scene.removeChild(element)

      true

  # Construct the exports...
  packets = {
    "Introducing" : PacketIntroducing
    "Update" : PacketUpdate
    "Gone" : PacketGone
  }

  dictionary = {}

  for key, value of packets
    dictionary[value.id] = value

  {
    packets : packets
    dictionary : dictionary
  }
