// Generated by CoffeeScript 1.4.0
(function() {

  require.config({
    urlArgs: "nonce=" + (new Date()).getTime()
  });

  require(["/app/components/jquery/dist/jquery.js", '/app/components/threejs/build/three.js', "/app/src/client.js"], function(_jquery, _three, Client) {
    return $(function() {
      return window.client = new Client;
    });
  });

}).call(this);
