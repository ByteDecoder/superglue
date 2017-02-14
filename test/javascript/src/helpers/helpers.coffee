
@testWithSession = (desc, callback) ->
  QUnit.test desc, (assert)->
    iframe = document.getElementById('pl-session')
    iframe.setAttribute('scrolling', 'yes')
    iframe.setAttribute('style', 'visibility: hidden;')
    iframe.setAttribute('src', "/app/session")
    document.body.appendChild(iframe)
    done = assert.async()

    iframe.onload = =>
      iframe.onload = null

      @window = iframe.contentWindow
      @document = @window.document
      @Relax = @window.Relax
      @location = @window.location
      @history = @window.history
      @Relax.disableRequestCaching()
      @$ = (selector) => @document.querySelector(selector)

      callback.call(@, assert)
      done()


