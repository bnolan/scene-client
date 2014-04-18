define [
  "/app/src/elements/model.js"
], (Model) ->
  class Uploader
    constructor: (@client) ->
      @endpoint = "//localhost:8090/upload"

      $('body').on 'dragover', (e) =>
        if !@message
          @createElements()

        @position = @client.detectCollision(e.originalEvent.clientX, e.originalEvent.clientY)
        @position.y = 20

    createElements: ->
      @message = $("<div />").addClass("upload-message").html('''
        <h1>Drop a file to upload..</h1

        <p>
          Currently only collada <code>.dae</code> is supported, and materials and textures are discarded.
        </p>
      ''').appendTo 'body'

      @overlay = $("<div />").addClass('upload-overlay').appendTo 'body'

      @form = $("<form method='post' enctype='multipart/form-data' action='#{@endpoint}' />").addClass('upload-form').html('''
        <input type="file" name="upload" />
      ''').appendTo 'body'

      @form.find('input').change (e) =>
        @submit()
        setTimeout(
          => @message.html("<h1>Uploading...</h1><p>This may take a while...</p>") # 
        , 200)

    removeElements: ->
      @message.remove()
      @overlay.remove()
      @form.remove()
      @message = @overlay = @form = null

    onSuccess: (text) =>
      console.log "file upload complete.."
      console.log text
      @removeElements()

      element = new Model
      element.src = text
      element.position = @position
      element.rotation.y = -Math.PI/2
      element.scale.x = element.scale.y = element.scale.z = 40.0

      # Send an introduction packet to the server...
      # I wonder if we should just send some javascript to the server to do this... I guess I'd need
      # to work out how to sandbox properly in node.js before we allowed that.
      packet = new Packet.Introducing(null, element.innerXML)
      client.connector.sendPackets([packet.toWireFormat()])


    submit: ->
      # @form.submit()
      # return

      file = @form.find('input').get(0).files[0]

      unless file.name.match /dae$/i
        alert "Sorry, only files of type .dae (collada) are able to be uploaded..."
        return

      unless @position
        alert "Sorry, couldnt detect drop position..."
        return

      $.ajax {
        type : "post"
        url : @endpoint
        data : new FormData(@form.get(0))
        processData : false
        contentType : false
        success : @onSuccess

        error: (response, text) =>
          console.log "error contacting ASSet server..."
          console.log "Error was: " + text
          @removeElements()

        xhrFields: {
          # add listener to XMLHTTPRequest object directly for progress (not sure if using deferred works)
          onprogress: (progress) ->
            # calculate upload progress
            percentage = Math.floor((progress.total / progress.totalSize) * 100);

            # log upload progress to console
            console.log('progress', percentage);

            if percentage == 100
              console.log('done uploading...!');
        }
      }

  Uploader