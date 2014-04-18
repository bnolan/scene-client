define [
  '/app/src/uploader.js'
], (Uploader) ->

  describe 'uploader', ->
    beforeEach ->
      @client = { connector : {} }
      @uploader = new Uploader @client
      @uploader.position = new THREE.Vector3 1, 2, 3

    it 'should create a packet on success', ->
      spyOn(@client.connector, 'sendPackets')
      @uploader.onSuccess '//asset-server/models/123.js'
      expect(@client.connector.sendPackets).toHaveBeenCalled()
