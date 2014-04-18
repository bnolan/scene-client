// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["/app/src/scene.js", "/app/src/connector.js", "/app/src/uploader.js", "/app/src/elements/box.js", "/app/src/elements/model.js", "/app/components/jquery/dist/jquery.js", "/app/components/stats.js/build/stats.min.js", "/app/components/dat-gui/build/dat.gui.js"], function(Scene, Connector, Uploader, Box, Model, _jquery, _stats, _dat) {
    var Client;
    Client = (function() {

      function Client() {
        this.tick = __bind(this.tick, this);

        var ASPECT, FAR, NEAR, VIEW_ANGLE, axes;
        this.scene = new Scene;
        this.connector = new Connector(this.scene);
        this.connector.connect();
        this.uploader = new Uploader(this);
        this.width = $(window).width();
        this.height = $(window).height();
        this.stats = new Stats();
        this.stats.setMode(0);
        this.stats.domElement.style.position = 'absolute';
        this.stats.domElement.style.left = '0px';
        this.stats.domElement.style.top = '0px';
        document.body.appendChild(this.stats.domElement);
        VIEW_ANGLE = 45;
        ASPECT = this.width / this.height;
        NEAR = 0.1;
        FAR = 20000;
        this.tscene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
        this.tscene.add(this.camera);
        this.camera.position.set(0, 150, 400);
        this.camera.lookAt(this.tscene.position);
        this.renderer = new THREE.WebGLRenderer({
          antialias: true
        });
        this.renderer.setSize(this.width, this.height);
        this.renderer.shadowMapEnabled = true;
        this.renderer.setClearColor(0xffffff, 1);
        this.projector = new THREE.Projector();
        this.addLights();
        this.addFloor();
        this.addControls();
        axes = new THREE.AxisHelper(100);
        this.tscene.add(axes);
        document.body.appendChild(this.renderer.domElement);
        this.tick();
      }

      Client.prototype.addFloor = function() {
        var floorGeometry, floorMaterial, floorTexture;
        floorTexture = new THREE.ImageUtils.loadTexture('/public/images/grid.png');
        floorTexture.wrapS = floorTexture.wrapT = THREE.RepeatWrapping;
        floorTexture.repeat.set(100, 100);
        floorMaterial = new THREE.MeshBasicMaterial({
          map: floorTexture
        });
        floorGeometry = new THREE.PlaneGeometry(1000, 1000, 1, 1);
        this.floor = new THREE.Mesh(floorGeometry, floorMaterial);
        this.floor.position.y = 0;
        this.floor.rotation.x = -Math.PI / 2;
        this.floor.receiveShadow = true;
        return this.tscene.add(this.floor);
      };

      Client.prototype.addControls = function() {
        return this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      };

      Client.prototype.addLights = function() {
        var ambientLight, dirLight;
        dirLight = new THREE.DirectionalLight(0xffffff, 1.0);
        dirLight.position.set(-1, 0.75, 1);
        dirLight.position.multiplyScalar(200);
        dirLight.name = "dirlight";
        this.tscene.add(dirLight);
        dirLight.castShadow = true;
        dirLight.shadowMapWidth = dirLight.shadowMapHeight = 512;
        ambientLight = new THREE.AmbientLight(0x111111);
        return this.tscene.add(ambientLight);
      };

      Client.prototype.generateMesh = function(element) {
        var cubeGeometry, loader, material, mesh,
          _this = this;
        element.tmodel = {};
        loader = new THREE.JSONLoader;
        loader.crossOrigin = "";
        if (element instanceof Box) {
          material = new THREE.MeshLambertMaterial({
            color: 0xFF00aa
          });
          cubeGeometry = new THREE.CubeGeometry(1, 1, 1, 1, 1, 1);
          mesh = new THREE.Mesh(cubeGeometry, material);
          mesh.castShadow = true;
          this.tscene.add(mesh);
          element.tmodel = mesh;
        }
        if (element instanceof Model) {
          return loader.load(element.src, function(geometry, materials) {
            material = new THREE.MeshFaceMaterial(materials);
            mesh = new THREE.Mesh(geometry, material);
            mesh.castShadow = true;
            _this.tscene.add(mesh);
            return element.tmodel = mesh;
          });
        }
      };

      Client.prototype.detectCollision = function(x, y) {
        var i, intersects, raycaster, vector, _i, _len;
        vector = new THREE.Vector3((x / this.width) * 2 - 1, -(y / this.height) * 2 + 1, 0.5);
        this.projector.unprojectVector(vector, this.camera);
        raycaster = new THREE.Raycaster(this.camera.position, vector.sub(this.camera.position).normalize());
        intersects = raycaster.intersectObjects([this.floor]);
        for (_i = 0, _len = intersects.length; _i < _len; _i++) {
          i = intersects[_i];
          return i.point;
        }
      };

      Client.prototype.assetServerHost = function() {
        return window.location.host.split(':')[0] + ":8090";
      };

      Client.prototype.addHomer = function() {
        var loader,
          _this = this;
        loader = new THREE.JSONLoader;
        return loader.load('/public/models/homer.js', function(geometry, materials) {
          var material, mesh;
          material = new THREE.MeshFaceMaterial(materials);
          mesh = new THREE.Mesh(geometry, material);
          mesh.rotation.y = -Math.PI / 2;
          mesh.castShadow = true;
          mesh.scale.x = mesh.scale.y = mesh.scale.z = 40.0;
          _this.tscene.add(mesh);
          return _this.selectModel(mesh);
        });
      };

      Client.prototype.addModel = function(url, position) {
        var loader,
          _this = this;
        loader = new THREE.JSONLoader;
        return loader.load(url, function(geometry) {
          var material, mesh;
          material = new THREE.MeshLambertMaterial({
            color: 0xDDDDDD
          });
          mesh = new THREE.Mesh(geometry, material);
          mesh.rotation.y = -Math.PI / 2;
          mesh.castShadow = true;
          mesh.position = position;
          mesh.scale.x = mesh.scale.y = mesh.scale.z = 40.0;
          _this.tscene.add(mesh);
          return _this.selectModel(mesh);
        });
      };

      Client.prototype.selectModel = function(mesh) {
        var f1, f2, f3, gui, max, min, range;
        return;
        gui = new dat.GUI();
        f1 = gui.addFolder('Rotation');
        f1.add(mesh.rotation, 'x', -Math.PI, Math.PI);
        f1.add(mesh.rotation, 'y', -Math.PI, Math.PI);
        f1.add(mesh.rotation, 'z', -Math.PI, Math.PI);
        range = 250;
        f2 = gui.addFolder('Position');
        f2.add(mesh.position, 'x', mesh.position.x - range, mesh.position.x + range);
        f2.add(mesh.position, 'y', mesh.position.y - range, mesh.position.y + range);
        f2.add(mesh.position, 'z', mesh.position.z - range, mesh.position.z + range);
        min = 0.1;
        max = 100;
        f3 = gui.addFolder('Scale');
        f3.add(mesh.scale, 'x', min, max);
        f3.add(mesh.scale, 'y', min, max);
        return f3.add(mesh.scale, 'z', min, max);
      };

      Client.prototype.addSuzanne = function(position) {
        var loader,
          _this = this;
        loader = new THREE.ColladaLoader();
        loader.options.convertUpAxis = true;
        return loader.load('/public/models/suzanne.dae', function(collada) {
          var model, _i, _len, _ref, _results;
          _ref = collada.scene.children;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            model = _ref[_i];
            if (!(model instanceof THREE.Mesh)) {
              continue;
            }
            model.scale.x = model.scale.y = model.scale.z = 20.0;
            model.rotation.x = Math.PI / 2;
            model.position = position;
            model.castShadow = true;
            _results.push(_this.tscene.add(model));
          }
          return _results;
        });
      };

      Client.prototype.tick = function() {
        var element, key, _ref;
        this.stats.begin();
        TWEEN.update();
        _ref = this.scene.childNodes;
        for (key in _ref) {
          element = _ref[key];
          if (!element.tmodel) {
            this.generateMesh(element);
          }
          element.tmodel.position = element.position;
          element.tmodel.rotation = element.rotation;
          element.tmodel.scale = element.scale;
        }
        this.controls.update();
        this.renderer.render(this.tscene, this.camera);
        this.stats.end();
        return requestAnimationFrame(this.tick);
      };

      return Client;

    })();
    return Client;
  });

}).call(this);
