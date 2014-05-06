# Fixme - msgpack has to be loaded manually, won't work with require.js for some reason :(
define [
  "/app/components/msgpack-js-browser/msgpack.js",
  "/app/src/packets.js"
], (msgpack_, Packets) ->

  class Connector
    constructor: (@scene, @camera, host, port) ->
      @host = host || window.location.host.split(":")[0]
      @port = port || 8080
      @protocol = "mv-protocol"
      @packets = []

    connect: ->
      @ws = new WebSocket("ws://#{@host}:#{@port}/", @protocol);
      @ws.binaryType = 'arraybuffer'
      @ws.onopen = =>
        console.log "Opened socket"
        @interval = setInterval @tick, 1000 / 2
      @ws.onclose = =>
        console.log "Closed socket"
        clearInterval @interval
      @ws.onmessage = @onMessage

    sendPacket: (packet) ->
      @packets.push packet

    dispatchPackets: ->
      @ws.send(msgpack.encode(@packets))

    tick: ->

      
    onMessage: (e) =>
      messages = msgpack.decode(e.data)

      for message in messages
        packetId = message[0]
        klass = Packets.dictionary[packetId]

        packet = new klass(message)
        packet.process(@scene)

      if @packets.length > 0
        @dispatchPackets()

      @packets = []
    
  Connector