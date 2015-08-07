AtomRoosterView = require './atom-rooster-view'
{CompositeDisposable, Range} = require 'atom'
{Sentences} = require './coq-sentences'
{$} = require 'atom-space-pen-views'

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

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'atom-rooster:mark_sentences': => @mark_sentences()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomRoosterView.destroy()

  serialize: ->
    atomRoosterViewState: @atomRoosterView.serialize()

  consumeStatusBar: (statusBar) ->
    content = $("<span>Coq is not running</span>")
    console.log content
    statusBarTile = statusBar.addLeftTile(item: content,
      priority: 100)

  toggle: ->
    console.log 'AtomRooster was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  mark_sentences: ->
    editor = atom.workspace.getActiveTextEditor()
    sentences = new Sentences(editor.getText())
    i = 0
    for sentence in sentences.sentences
      buffer = editor.getBuffer()
      start = buffer.positionForCharacterIndex(sentence.start+1)
      stop = buffer.positionForCharacterIndex(sentence.stop-1)
      marker = editor.markBufferRange(new Range(start, stop))
      if i%2 == 0
        css_class = "sentence0"
      else
        css_class = "sentence1"
      editor.decorateMarker(marker,
        {type: 'highlight',
        class: css_class})
      i += 1

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
