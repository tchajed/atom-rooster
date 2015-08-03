{Lexer, sentences} = require '../lib/coq-sentences.coffee'

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
  it 'should return sentence locations', ->
    code = """
      foo.
      bar.
      (* a *).
    """.trim()
    expect(sentences(code)).toEqual [
      {start: 0,    stop: 4},
      {start: 4,    stop: 4+5}, # includes newline
      {start: 4+5,  stop: code.length},
    ]
