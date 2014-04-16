# Fixme - msgpack has to be loaded manually, won't work with require.js for some reason :(
define [
  "/app/components/msgpack-js-browser/msgpack.js",
  "/app/src/packets.js"
], (msgpack_, Packets) ->

  class Connector
    constructor: (@scene, host, port) ->
      @host = window.location.host.split(":")[0]
      @port = 8080
      @protocol = "mv-protocol"

      @ws = new WebSocket("ws://#{@host}:#{@port}/", @protocol);

      @ws.binaryType = 'arraybuffer'

      @ws.onopen = =>
        console.log "Opened socket"
      @ws.onclose = =>
        console.log "Closed socket"
      @ws.onmessage = @onMessage

    onMessage: (e) =>
      messages = msgpack.decode(e.data)

      for message in messages
        packetId = message[0]
        klass = Packets.dictionary[packetId]

        packet = new klass(message)
        packet.process(@scene)
    
  Connector