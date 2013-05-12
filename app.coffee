{EventEmitter} = require "events"
_ = require "lodash"
moment = require "moment"
blessed = require "blessed"

class InteractiveTerminal extends EventEmitter
  constructor: ->
    @program = blessed()

    @program.on "keypress", (ch, key) =>
      if key.name == "q"
        @emit "exit"

    @lastMouseDown = {}

    # support is pretty weird for stuff so left mouse button only, move, down, and up events with x and y
    # also wheeldown and wheelup
    @program.on "mouse", (data) =>
      event =
        # 0 index it
        x: data.x - 1
        y: data.y - 1

      # normalize the event, I don't even
      if data.action == "mousedown" && data.button == "unknown"
        event.action = "mousemove"
      else
        event.action = data.action

      @emit event.action, event

      # Detect clicks, because only horrible people do things on mouse down/up
      if event.action == "mousedown"
        @lastMouseDown = event
      else if event.action == "mouseup"
        if @lastMouseDown.x == event.x && @lastMouseDown.y == event.y
          @emit "click", _.extend {action: "click"}, event

    @program.alternateBuffer()
    @program.enableMouse()
    @program.hideCursor()
    @program.clear()

  clear: -> @program.clear()
  move: (x, y) -> @program.move x + 1, y + 1 # 0 index that crap!
  write: (text) -> @program.write text
  bg: (color) -> @program.bg color
  getWindowSize: (cb) -> @program.getWindowSize cb

  end: ->
    @program.clear()
    @program.disableMouse()
    @program.showCursor()
    @program.normalBuffer()


class InteractiveDebugger
  constructor: ->
    @iterm = new InteractiveTerminal()

    @buffer = []
    @hoverPosition = {}

    setTimeout =>
      @iterm.getWindowSize (err, {width, height}) =>
        @mainWidth = Math.ceil width / 2
        @sidebarWidth = width - @mainWidth
        console.log width, height
    , 1000

    # @iterm.on "click", (e) => console.log "click", e
    # @iterm.on "mousemove", (e) => console.log "mousemove", e
    # @iterm.on "mouseup", (e) => console.log "mouseup", e
    # @iterm.on "mousedown", (e) => console.log "mousedown", e
    # @iterm.on "wheelup", (e) => console.log "wheelup", e
    # @iterm.on "wheeldown", (e) => console.log "wheeldown", e

    @iterm.on "mousemove", @mousemove
    @iterm.on "click", @click

    @iterm.on "exit", =>
      @iterm.end()
      process.exit 0

  log: ->
    for argument in arguments
      @buffer.push argument
    @render()

  render: ->
    @iterm.clear()
    for line, i in @buffer
      lineColor = if i == @hoverPosition.y then "red" else "!red"
      @iterm.bg lineColor
      @iterm.move 0, i
      @iterm.write line.toString()

    @iterm.bg "!red"

  mousemove: (e) =>
    if e.x < @mainWidth
      @hoverPosition = {x: e.x, y: e.y}
      @render()

  click: (e) =>
    if e.x < @mainWidth
      console.log "asd"


class Sidebar
  constructor: ->

  display: (object) ->
    console.log "display"


  render: ->






idbg = new InteractiveDebugger()

idbg.log {"type":"expression","operator":"+","operands":[{"type":"expression","operator":"+","operands":[{"type":"variable","value":"1"},{"type":"variable","value":"5"}]},{"type":"variable","value":"8"}]}
idbg.log "name:", "Rob"


