define [
  "/app/src/scene.js",
  "/app/src/connector.js",
  "/app/src/uploader.js",
  "/app/src/elements/box.js",
  "/app/src/elements/model.js",
  "/app/components/jquery/dist/jquery.js", 
  "/app/components/stats.js/build/stats.min.js",
  "/app/components/dat-gui/build/dat.gui.js"
], (Scene, Connector, Uploader, Box, Model, _jquery, _stats, _dat) ->
  class Client
    constructor: ->
      @scene = new Scene

      @connector = new Connector(@scene)
      @connector.connect()
      
      @uploader = new Uploader(this)

      @width = $(window).width()
      @height = $(window).height()

      @stats = new Stats()
      @stats.setMode(0)

      @stats.domElement.style.position = 'absolute';
      @stats.domElement.style.left = '0px';
      @stats.domElement.style.top = '0px';
      document.body.appendChild(@stats.domElement)

      VIEW_ANGLE = 45
      ASPECT = @width / @height
      NEAR = 0.1
      FAR = 20000

      @tscene = new THREE.Scene()

      @camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR)
      @tscene.add(@camera)

      @camera.position.set(0,150,400)
      @camera.lookAt(@tscene.position)

      @renderer = new THREE.WebGLRenderer( {antialias:true} )
      @renderer.setSize(@width, @height)
      @renderer.shadowMapEnabled = true
      @renderer.setClearColor( 0xffffff, 1)

      @projector = new THREE.Projector()

      @addLights()
      @addFloor()
      @addControls()
      @addInstructions()

      axes = new THREE.AxisHelper(100)
      @tscene.add(axes)

      document.body.appendChild( @renderer.domElement );

      # @addHomer() # (new THREE.Vector3 0, 0, 0)
      @tick()

    addInstructions: ->
      $("#instructions").show()


    addFloor: ->
      floorTexture = new THREE.ImageUtils.loadTexture( '/public/images/grid.png' )
      floorTexture.wrapS = floorTexture.wrapT = THREE.RepeatWrapping;
      floorTexture.repeat.set( 100, 100 )

      floorMaterial = new THREE.MeshBasicMaterial( { map: floorTexture } );
      floorGeometry = new THREE.PlaneGeometry(1000, 1000, 1, 1)
      
      @floor = new THREE.Mesh(floorGeometry, floorMaterial)
      @floor.position.y = 0
      @floor.rotation.x = -Math.PI / 2
      @floor.receiveShadow = true

      @tscene.add(@floor)

    addControls: ->
      @controls = new THREE.OrbitControls( @camera, @renderer.domElement )

    addLights: ->
      # light = new THREE.PointLight(0xffffff)
      # light.position.set(0,250,0)
      # @tscene.add(light)

      dirLight = new THREE.DirectionalLight( 0xffffff, 1.0)
      dirLight.position.set( -1, 0.75, 1 )
      dirLight.position.multiplyScalar( 200)
      dirLight.name = "dirlight"
      # dirLight.shadowCameraVisible = true;

      @tscene.add( dirLight )

      dirLight.castShadow = true;
      dirLight.shadowMapWidth = dirLight.shadowMapHeight = 512;

      ambientLight = new THREE.AmbientLight(0x111111)
      @tscene.add(ambientLight)

    generateMesh: (element) ->
      element.tmodel = {} # some kind of stub - maybe a Promise?

      loader = new THREE.JSONLoader
      loader.crossOrigin = ""

      if element instanceof Box
        material = new THREE.MeshLambertMaterial( { color: 0xFF00aa } )
        cubeGeometry = new THREE.CubeGeometry(1, 1, 1, 1, 1, 1)
        mesh = new THREE.Mesh(cubeGeometry, material)
        mesh.castShadow = true
        @tscene.add(mesh) 
        element.tmodel = mesh

      if element instanceof Model
        loader.load element.src, (geometry, materials) =>
          material = new THREE.MeshFaceMaterial( materials )
          mesh = new THREE.Mesh(geometry,material)
          mesh.castShadow = true
          @tscene.add(mesh)
          element.tmodel = mesh

    detectCollision: (x,y) ->
      vector = new THREE.Vector3( ( x / @width ) * 2 - 1, - ( y / @height ) * 2 + 1, 0.5 )
      @projector.unprojectVector( vector, @camera )
      raycaster = new THREE.Raycaster( @camera.position, vector.sub( @camera.position ).normalize() )
      intersects = raycaster.intersectObjects([@floor])

      for i in intersects
        return i.point

    assetServerHost: ->
      window.location.host.split(':')[0] + ":8090"

    addHomer: ->
      loader = new THREE.JSONLoader

      # loader.load "//#{@assetServerHost()}/models/homer.js", (geometry, materials) =>
      loader.load '/public/models/homer.js', (geometry, materials) =>
        material = new THREE.MeshFaceMaterial( materials )

        # create a mesh with models geometry and material
        mesh = new THREE.Mesh(
          geometry,
          material
        )
        #   material
        # )
        
        mesh.rotation.y = -Math.PI/2
        mesh.castShadow = true
        mesh.scale.x = mesh.scale.y = mesh.scale.z = 40.0
        
        @tscene.add(mesh)

        @selectModel(mesh)


    addModel: (url, position) ->
      loader = new THREE.JSONLoader

      loader.load url, (geometry) =>
        material = new THREE.MeshLambertMaterial( { color: 0xDDDDDD } )
        
        # create a mesh with models geometry and material
        mesh = new THREE.Mesh(
          geometry,
          material
        )
        
        mesh.rotation.y = -Math.PI/2
        mesh.castShadow = true
        mesh.position = position
        mesh.scale.x = mesh.scale.y = mesh.scale.z = 40.0
        
        @tscene.add(mesh)

        @selectModel(mesh)

    selectModel: (mesh) ->
      return

      gui = new dat.GUI()

      f1 = gui.addFolder('Rotation')
      f1.add(mesh.rotation, 'x', -Math.PI, Math.PI)
      f1.add(mesh.rotation, 'y', -Math.PI, Math.PI)
      f1.add(mesh.rotation, 'z', -Math.PI, Math.PI)

      range = 250
      f2 = gui.addFolder('Position')
      f2.add(mesh.position, 'x', mesh.position.x - range, mesh.position.x + range)
      f2.add(mesh.position, 'y', mesh.position.y - range, mesh.position.y + range)
      f2.add(mesh.position, 'z', mesh.position.z - range, mesh.position.z + range)

      min = 0.1
      max = 100
      f3 = gui.addFolder('Scale')
      f3.add(mesh.scale, 'x', min, max)
      f3.add(mesh.scale, 'y', min, max)
      f3.add(mesh.scale, 'z', min, max)


    addSuzanne: (position) ->
      loader = new THREE.ColladaLoader()
      loader.options.convertUpAxis = true
      loader.load '/public/models/suzanne.dae', (collada) =>
        for model in collada.scene.children when model instanceof THREE.Mesh
          # skin = collada.skins[0]
          model.scale.x = model.scale.y = model.scale.z = 20.0
          model.rotation.x = Math.PI / 2
          model.position = position
          model.castShadow = true
          # dae.updateMatrix()
          @tscene.add(model)
          # alert "?"


    tick: =>
      @stats.begin()

      TWEEN.update()

      for key, element of @scene.childNodes
        if !element.tmodel
          @generateMesh(element)

        element.tmodel.position = element.position
        element.tmodel.rotation = element.rotation
        element.tmodel.scale = element.scale

      @controls.update()
      @renderer.render( @tscene, @camera )

      @stats.end()

      requestAnimationFrame @tick

  Client