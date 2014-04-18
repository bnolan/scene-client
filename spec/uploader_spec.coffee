define [
  '/app/src/uploader.js'
], (Uploader) ->

  describe 'uploader', ->
    beforeEach ->
      @client = { 
        connector : { 
          sendPacket : -> true
        } 
      }
      @uploader = new Uploader @client
      @uploader.position = new THREE.Vector3 1, 2, 3

    it 'should create a packet on success', ->
      spyOn(@client.connector, 'sendPacket')
      @uploader.onSuccess '//asset-server/models/123.js'
      expect(@client.connector.sendPacket).toHaveBeenCalled()

      xml = @client.connector.sendPacket.mostRecentCall.args[0][1]

      expect(xml).toMatch /<model/
      expect(xml).toMatch /position=.1 2 3/
      expect(xml).toMatch /asset-server.models.123/


