coqslave = require 'coq-slave'
Document = require '../lib/document.coffee'

class Coq
  constructor: () ->
    @coq = new coqslave.Coqtop()

  init: (filename) ->
    @doc = new Document()
    @doc.push null
    @coq.init(filename)
    .then (sid) =>
      @doc.assign_tip_id sid

  add: (sentence) ->
    tip = @doc.tip()
    @doc.push sentence
    @coq.add(sentence, 0, tip, true)
    .then ({state_id, res}) =>
      @doc.assign_tip_id state_id
      if res != ""
        console.log res
    .catch (err) ->
      console.error err

  quit: () ->
    @coq.quit()

module.exports = Coq
