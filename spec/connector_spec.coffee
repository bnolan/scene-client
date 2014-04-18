define [
  '/app/src/connector.js',
  '/app/src/packets.js'
], (Connector, Packets) ->

  describe 'connector', ->
    beforeEach ->
      @scene = {}
      @connector = new Connector @scene
      @connector.ws = {
        send : -> true
      }

    it 'should encode valid msgpack', ->
      @connector.sendPacket([0x01, "<xml something />"])
      spyOn(@connector.ws, 'send')
      @connector.dispatchPackets()
      buf = @connector.ws.send.mostRecentCall.args[0]
      expect(buf.byteLength).toEqual(21)
