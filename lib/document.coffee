# Port of ide/document structure from CoqIDE

class Sentence
  constructor: (@id, @data) ->

Empty = new Error("Empty document")

class Document
  constructor: () ->
    @stack = []

  _top_el: () ->
    if @stack.length == 0
      throw Empty
    return @stack[@stack.length - 1]

  # invariant: only the tip may lack an id; check that it has one before
  # adding on to it
  _invariant_check: () ->
    if @stack.length != 0 and not @_top_el().id?
      throw new Error("invariant broken")

  tip: () ->
    id = @_top_el().id
    if not id?
      throw new Error("Tip id unassigned")
    return id

  push: (sentence) ->
    @_invariant_check()
    @stack.push new Sentence(null, sentence)

  assign_tip_id: (id) ->
    @_top_el().id = id

  pop: (sentence) ->
    if @stack.length == 0
      throw Empty
    return @sentences.shift().data

module.exports = Document
