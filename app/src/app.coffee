require.config {
    urlArgs : "nonce=" + (new Date()).getTime()
}

require [
  "/app/components/jquery/dist/jquery.js", 
  '/app/components/threejs/build/three.js',
  "/app/src/client.js",
], (_jquery, _three, Client) ->
  $ -> window.client = new Client
