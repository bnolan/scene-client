require.config {
    urlArgs : "nonce=" + (new Date()).getTime()
}

define [
  "/app/components/jasmine/lib/jasmine-core/jasmine.js",
  "/app/components/jasmine/lib/jasmine-core/jasmine-html.js",
  "/app/components/jquery/dist/jquery.js", 
  "/app/components/threejs/build/three.js", 
  "./uploader_spec.js"
], () ->
  # jasmine.getEnv().addReporter(new jasmine.HtmlReporter())
  # jasmine.getEnv().execute()

  jasmineEnv = jasmine.getEnv()
  jasmineEnv.updateInterval = 1000

  trivialReporter = new jasmine.HtmlReporter()

  jasmineEnv.addReporter(trivialReporter)

  jasmineEnv.specFilter = (spec) ->
    trivialReporter.specFilter(spec)

  jasmineEnv.execute()
  
