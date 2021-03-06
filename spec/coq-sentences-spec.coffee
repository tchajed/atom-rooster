{Lexer, Sentences} = require '../lib/coq-sentences.coffee'
require 'jasmine-expect'

string = (s) ->
  new Lexer.StringTok(s)

tokens = (s) ->
  lexer = new Lexer(s)
  toks = []
  while (tok = lexer.lex()) != Lexer.EOF
    toks.push tok
  return toks

describe 'Lexer', ->
  describe 'basic tokenization', ->
    it 'should lex non-special characters individually', ->
      expect(tokens "normal").toEqual "normal".split("")

  describe 'string tokenization', ->
    it 'should lex a complete string', ->
      s = """ a "bar" """.trim()
      expect(tokens s).toEqual ["a", " ", string("bar")]

    it 'should lex an incomplete string', ->
      s = """ a "bar """.trim()
      expect(tokens s).toEqual ["a", " ", string("bar")]

    it 'should include comments', ->
      s = """ "(*foo*)" """.trim()
      expect(tokens s).toEqual [string("(*foo*)")]

  describe 'comment tokenization', ->
    it 'should ignore comments', ->
      s = """a(* foo *)b"""
      expect(tokens s).toEqual ["a", "b"]

    it 'should ignore adjacent comments', ->
      s = """a(* foo *)(* bar *)c"""
      expect(tokens s).toEqual ["a", "c"]

    it 'should handle imbalanced parens', ->
      s = """a(() *"""
      expect(tokens s).toEqual s.split('')

    it 'should handle nesting', ->
      s = """(* (* foo *) *)"""
      expect(tokens s).toEqual []

    it 'should handle early termination', ->
      s = """a (* foo"""
      expect(tokens s).toEqual ["a", " "]

    it 'should handle nested early termination', ->
      s = """a (* (* foo *) ab"""
      expect(tokens s).toEqual ["a", " "]

describe 'Sentence splitter', ->
  expectCount = (count, code) ->
    expect(new Sentences(code).sentences).toBeArrayOfSize(count)

  expectSingle = (code) ->
    expectCount(1, code)

  describe 'basic code snippet', ->
    [code, sentences] = []

    beforeEach ->
      code = """
        foo.
        bar.
        (* a *).
      """.trim()
      sentences = new Sentences(code)

    it 'should return sentence locations', ->
      expect(sentences.sentences).toEqual [
        {start: 0,    stop: 4},
        {start: 4,    stop: 4+5}, # includes newline
        {start: 4+5,  stop: code.length},
      ]

    it 'should locate surrounding sentence', ->
      expect(sentences.boundaries(3)).toEqual {start: 0, stop: 4}
      expect(sentences.boundaries(4)).toEqual {start: 4, stop: 4+5}
      expect(sentences.boundaries(9)).toEqual {start: 9, stop: code.length}
      expect(sentences.boundaries(code.length)).toBe null

    it 'should handle comments with periods', ->
      expectCount 3, """
      Require Import Omega.

      (* this comment ends with a period (regression test). *)
      Foo.
      Bar.
      """

    it 'should handle comment with incomplete string', ->
      expectCount 2, """
      (* here's a " string *)
      Foo.
      Bar.
      """

    it 'should handle comment with bullets', ->
      expectCount 2, """
      (** list:
      * foo
      * bar *)
      Foo.
      Bar.
      """

  describe 'non-sentence periods', ->
    it 'should ignore module names', ->
      expectSingle 'Import Coq.Arith.Factorial.'

    it 'should ignore field-access method calls', ->
      expectSingle 'let size := ck.(chunk_size)'

    it 'should ignore recursive notation patterns', ->
      expectSingle 'Notation "[a ; .. ; b]" := (cons a ( .. (cons b nil) ..)).'

  describe 'focus syntax', ->
    it 'should handle record syntax', ->
      expectSingle """
        foo := {
          a: 1
          b: 2
        }.
        """

   it 'should parse initial brackets', ->
    expectCount 2, """
      foo. {
      """
    expectCount 2, """
      foo.
      {
      """

  it 'should parse closing brackets', ->
    expectCount 4, """
      foo.
      { foo bar. }
      """
    expectCount 4, """
      foo.
      { foo bar.
      }
      """

  it 'should parse single-char bullets', ->
    expectCount 4, """
      * foo.
      * bar.
      """
    expectCount 4, """
      + foo. + bar.
      """
    expectCount 5, """
      foo. - a.
      - b.
      """

  it 'should parse multi-char bullets', ->
    expectCount 2, """
      ++ foo.
      """
    expectCount 4, """
        --- bar.
        ++ foo.
        """
    expectCount 3, """
      foo. ** bar.
      """
