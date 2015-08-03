Coq = require '../lib/coq.coffee'

describe 'Coq', ->
  coq = undefined

  beforeEach ->
    coq = new Coq

  it 'can initialize', ->
    waitsForPromise ->
      coq.init()
      .then ->
        coq.quit()

  it 'can prove a theorem', ->
    waitsForPromise ->
      coq.init()
      .then ->
        coq.add("Theorem t : forall n:nat, n = n + O.")
      .then ->
        coq.add("intros.")
      .then ->
        coq.add("reflexivity.")
      .then ->
        coq.add("Qed.")
      .then ->
        coq.quit()
