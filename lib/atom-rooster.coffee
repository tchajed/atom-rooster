AtomRoosterView = require './atom-rooster-view'
{CompositeDisposable} = require 'atom'
{Sentences} = require './coq-sentences'

module.exports = AtomRooster =
  atomRoosterView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomRoosterView = new AtomRoosterView(state.atomRoosterViewState)
    @modalPanel = atom.workspace.addModalPanel(
      item: @atomRoosterView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-rooster:toggle': => @toggle()

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'atom-rooster:find_stop': => @find_stop()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomRoosterView.destroy()

  serialize: ->
    atomRoosterViewState: @atomRoosterView.serialize()

  toggle: ->
    console.log 'AtomRooster was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  find_stop: ->
    editor = atom.workspace.getActiveTextEditor()
    pos = editor.getCursorBufferPosition()
    offset = editor.getBuffer().characterIndexForPosition(pos)
    sentences = new Sentences(editor.getText())
    sentence_stop = sentences.boundaries(offset)?.stop
    if not sentence_stop?
      return
    stop_pos = editor.getBuffer().positionForCharacterIndex(sentence_stop)
    cursor = editor.getLastCursor()
    cursor.setBufferPosition(stop_pos)
