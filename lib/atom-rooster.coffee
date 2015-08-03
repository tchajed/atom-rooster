AtomRoosterView = require './atom-rooster-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomRooster =
  atomRoosterView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomRoosterView = new AtomRoosterView(state.atomRoosterViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomRoosterView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-rooster:toggle': => @toggle()

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
